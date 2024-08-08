package main

import (
	"encoding/xml"
	"fmt"
	"io"
	"log"
	"os"
	"path/filepath"
	"strings"
)

type CSharpProjectFile struct {
	XMLName       xml.Name `xml:"Project"`
	SDK           string   `xml:"Sdk,attr"`
	PropertyGroup PropertyGroup
}

type PropertyGroup struct {
	AssemblyName    string
	TargetFramework string
}

func getXMLFromFile(fileName string) (*CSharpProjectFile, error) {
	file, err := os.Open(fileName)
	if err != nil {
		log.Fatalf("Failed to open csproj file: %s", err)
	}

	bytes, err := io.ReadAll(file)
	if err != nil {
		return nil, fmt.Errorf("getXMLFromFile: Failed to read file: %s", err)
	}

	var project CSharpProjectFile
	err = xml.Unmarshal(bytes, &project)
	if err != nil {
		return nil, fmt.Errorf("getXMLFromFile: Failed to unmarshal file: %s", err)
	}

	return &project, nil
}

func findAssemblyName(csprojFileRelativePath string, csprojFileName string, testing bool) (string, error) {
	var assemblyName string
	if !testing {
		csprojXml, err := getXMLFromFile(csprojFileRelativePath)
		if err != nil {
			return "", err
		}

		assemblyName = csprojXml.PropertyGroup.AssemblyName
	}

	if len(assemblyName) == 0 {
		basename := filepath.Base(csprojFileName)
		withoutExtension := strings.TrimSuffix(basename, filepath.Ext(basename))

		return withoutExtension + ".dll", nil
	}

	return assemblyName, nil
}

func findBaseImageTag(csprojFileRelativePath string) (string, error) {
	csprojXml, err := getXMLFromFile(csprojFileRelativePath)
	if err != nil {
		return "", err
	}

	targetFramework := csprojXml.PropertyGroup.TargetFramework
	if len(targetFramework) == 0 {
		return "", fmt.Errorf(
			"findBaseImageTag: TargetFramework not found in csproj file: %s",
			csprojFileRelativePath,
		)
	}

	return targetFramework[3:] + "-alpine", nil

}

func findRuntimeBaseImage(csprojFileRelativePath string) (string, error) {
	csprojXml, err := getXMLFromFile(csprojFileRelativePath)
	if err != nil {
		return "", err
	}

	sdk := csprojXml.SDK
	if len(sdk) == 0 {
		return "", fmt.Errorf(
			"SDK not found in csproj file: %s",
			csprojFileRelativePath,
		)
	}

	switch sdk {
	case "Microsoft.NET.Sdk":
		return "mcr.microsoft.com/dotnet/runtime", nil
	case "Microsoft.NET.Sdk.Web",
		"Microsoft.NET.Sdk.BlazorWebAssembly",
		"Microsoft.NET.Sdk.Razor",
		"Microsoft.NET.Sdk.Worker":
		return "mcr.microsoft.com/dotnet/aspnet", nil
	default:
		return "", fmt.Errorf("Unknown SDK: %s", sdk)
	}
}

type DotnetDockerfileVariables struct {
	AssemblyName       string // required
	BaseImageTag       string // required
	RuntimeBaseImage   string // required
	CsprojFile         string // required
	IncludeFiles       []string
	IncludeDirectories []string
}

func writeDockerfileDotnet(
	actionPath string,
	dockerfileVariables DotnetDockerfileVariables,
) error {
	const templateFile = "Dockerfile.dotnet.tmpl"
	return writeDockerfile(actionPath, templateFile, dockerfileVariables)
}
