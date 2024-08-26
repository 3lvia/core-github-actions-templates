package main

import (
	"bytes"
	"fmt"
	"log"
	"os"
	"path"
	"strings"
	"text/template"
)

func main() {
	csprojFileRelativePath := os.Getenv("CSPROJ_FILE")
	goModFileRelativePath := os.Getenv("GO_MOD_FILE")
	buildContextRelativePath := os.Getenv("DOCKER_BUILD_CONTEXT")
	includeFiles := getValuesFromCommaSeparatedString(os.Getenv("INCLUDE_FILES"))
	includeDirectories := getValuesFromCommaSeparatedString(os.Getenv("INCLUDE_DIRS"))
	actionPath := dotIfEmpty(os.Getenv("GITHUB_ACTION_PATH"))

	err := writeToGitHubOutput("DOCKERFILE=" + path.Join(actionPath, "Dockerfile"))
	if err != nil {
		log.Fatal(err)
	}

	if len(csprojFileRelativePath) != 0 {
		csprojFileName, buildContext := getProjectFileAndBuildContext(
			csprojFileRelativePath,
			buildContextRelativePath,
		)

		err = writeToGitHubOutput("DOCKER_BUILD_CONTEXT=" + buildContext)
		if err != nil {
			log.Fatal(err)
		}

		assemblyName, err := findAssemblyName(csprojFileRelativePath, csprojFileName, false)
		if err != nil {
			log.Fatal(err)
		}

		baseImageTag, err := findBaseImageTag(csprojFileRelativePath)
		if err != nil {
			log.Fatal(err)
		}

		runtimeBaseImage, err := findRuntimeBaseImage(csprojFileRelativePath)
		if err != nil {
			log.Fatal(err)
		}

		dockerfileVariables := DotnetDockerfileVariables{
			AssemblyName:       assemblyName,
			BaseImageTag:       baseImageTag,
			RuntimeBaseImage:   runtimeBaseImage,
			CsprojFile:         csprojFileName,
			IncludeFiles:       includeFiles,
			IncludeDirectories: includeDirectories,
		}
		if err := writeDockerfileDotnet(actionPath, dockerfileVariables); err != nil {
			log.Fatal(err)
		}
	} else if len(goModFileRelativePath) != 0 {
		moduleDirectory, buildContext := getModuleDirectoryAndBuildContext(
			goModFileRelativePath,
			buildContextRelativePath,
		)

		mainPackageDirectory := dotIfEmpty(os.Getenv("MAIN_PACKAGE_DIR"))

		err = writeToGitHubOutput("DOCKER_BUILD_CONTEXT=" + buildContext)
		if err != nil {
			log.Fatal(err)
		}

		dockerfileVariables := GoDockerfileVariables{
			ModuleDirectory:      moduleDirectory,
			MainPackageDirectory: mainPackageDirectory,
			BuildContext:         buildContext,
			IncludeFiles:         includeFiles,
			IncludeDirectories:   includeDirectories,
		}
		if err := writeDockerfileGo(actionPath, dockerfileVariables); err != nil {
			log.Fatal(err)
		}
	} else {
		log.Fatal("No csproj or go.mod file found")
	}

	fmt.Println("Dockerfile created successfully")
}

func dotIfEmpty(str string) string {
	if len(str) == 0 {
		return "."
	}

	return str
}

func getValuesFromCommaSeparatedString(files string) []string {
	if len(files) == 0 {
		return []string{}
	}

	return strings.Split(files, ",")
}

func writeDockerfile(
	actionPath string,
	templateFile string,
	dockerfileVariables any,
) error {
	dockerfile, err := os.Create(path.Join(actionPath, "Dockerfile"))
	if err != nil {
		return fmt.Errorf("Failed to create Dockerfile: %s", err)
	}

	defer dockerfile.Close()

	dockerfileTemplate, err := template.New(templateFile).ParseFiles(path.Join(actionPath, templateFile))
	if err != nil {
		return fmt.Errorf("Failed to parse Dockerfile template: %s", err)
	}

	var dockerfileBuffer bytes.Buffer
	err = dockerfileTemplate.Execute(&dockerfileBuffer, dockerfileVariables)
	if err != nil {
		return fmt.Errorf("Failed to execute Dockerfile template: %s", err)
	}

	if _, err := dockerfile.Write(dockerfileBuffer.Bytes()); err != nil {
		return fmt.Errorf("Failed to write Dockerfile: %s", err)
	}

	return nil
}

func writeToGitHubOutput(output string) error {
	githubOutput := os.Getenv("GITHUB_OUTPUT")
	if len(githubOutput) == 0 {
		return fmt.Errorf("GITHUB_OUTPUT not set.")
	}

	f, err := os.OpenFile(
		githubOutput,
		os.O_APPEND|os.O_CREATE|os.O_WRONLY,
		0644,
	)
	if err != nil {
		return err
	}

	defer f.Close()

	if _, err := f.WriteString(output + "\n"); err != nil {
		return err
	}

	return nil
}

func getProjectFileAndBuildContext(
	projectFileRelativePath string,
	buildContextRelativePath string,
) (string, string) {
	if len(buildContextRelativePath) == 0 {
		return path.Base(projectFileRelativePath), path.Dir(projectFileRelativePath)
	}

	if strings.HasSuffix(buildContextRelativePath, "/") {
		return strings.TrimPrefix(
			projectFileRelativePath,
			buildContextRelativePath,
		), buildContextRelativePath
	}

	return strings.TrimPrefix(
		projectFileRelativePath,
		buildContextRelativePath+"/",
	), buildContextRelativePath
}
