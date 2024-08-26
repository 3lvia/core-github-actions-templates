package main

import "strings"

type GoDockerfileVariables struct {
	ModuleDirectory      string // required
	MainPackageDirectory string // required
	BuildContext         string // required
	IncludeFiles         []string
	IncludeDirectories   []string
}

func writeDockerfileGo(
	actionPath string,
	dockerfileVariables GoDockerfileVariables,
) error {
	const templateFile = "Dockerfile.go.tmpl"
	return writeDockerfile(actionPath, templateFile, dockerfileVariables)
}

func getModuleDirectoryAndBuildContext(
	projectFileRelativePath string,
	buildContextRelativePath string,
) (string, string) {
	projectFileName, buildContext := getProjectFileAndBuildContext(
		projectFileRelativePath,
		buildContextRelativePath,
	)

	return dotIfEmpty(
		strings.TrimSuffix(
			strings.TrimSuffix(
				projectFileName,
				"go.mod",
			),
			"/",
		),
	), buildContext
}
