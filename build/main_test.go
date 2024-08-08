package main

import (
	"testing"
)

type projectFileBuildContextTest struct {
	projectFileRelativePath  string // required
	buildContextRelativePath string // required
	expectedProjectFileName  string // required
	expectedBuildContext     string // required
}

func TesDotnettGetProjectFileAndBuildContext(t *testing.T) {
	// files and directories must exist, since we read csproj files
	tests := []projectFileBuildContextTest{
		{
			projectFileRelativePath:  ".github/test/src/core-demo-api.csproj",
			buildContextRelativePath: "",
			expectedProjectFileName:  "core-demo-api.csproj",
			expectedBuildContext:     ".github/test/src",
		},
		{
			projectFileRelativePath:  ".github/test/src/core-demo-api.csproj",
			buildContextRelativePath: ".github/test",
			expectedProjectFileName:  "src/core-demo-api.csproj",
			expectedBuildContext:     ".github/test",
		},
	}

	for _, test := range tests {
		csprojFileName, buildContext := getProjectFileAndBuildContext(
			test.projectFileRelativePath,
			test.buildContextRelativePath,
		)

		if csprojFileName != test.expectedProjectFileName {
			t.Errorf(
				"Expected csprojFileName to be %s, got %s",
				test.expectedProjectFileName,
				csprojFileName,
			)
		}

		if buildContext != test.expectedBuildContext {
			t.Errorf(
				"Expected buildContext to be %s, got %s",
				test.expectedBuildContext,
				buildContext,
			)
		}
	}
}

type moduleDirectoryBuildContextTest struct {
	projectFileRelativePath  string // required
	buildContextRelativePath string // required
	expectedModuleDirectory  string // required
	expectedBuildContext     string // required
}

func TestGoGetModuleDirectoryAndBuildContext(t *testing.T) {
	// files and directories don't need to actually exist
	tests := []moduleDirectoryBuildContextTest{
		{
			projectFileRelativePath:  "go.mod",
			buildContextRelativePath: "",
			expectedModuleDirectory:  ".",
			expectedBuildContext:     ".",
		},
		{
			projectFileRelativePath:  "pkg/app/go.mod",
			buildContextRelativePath: "",
			expectedModuleDirectory:  ".",
			expectedBuildContext:     "pkg/app",
		},
		{
			projectFileRelativePath:  "pkg/app/go.mod",
			buildContextRelativePath: "pkg",
			expectedModuleDirectory:  "app",
			expectedBuildContext:     "pkg",
		},
		{
			projectFileRelativePath:  "pkg/app/module/go.mod",
			buildContextRelativePath: "pkg",
			expectedModuleDirectory:  "app/module",
			expectedBuildContext:     "pkg",
		},
	}

	for _, test := range tests {
		moduleDirectory, buildContext := getModuleDirectoryAndBuildContext(
			test.projectFileRelativePath,
			test.buildContextRelativePath,
		)

		if moduleDirectory != test.expectedModuleDirectory {
			t.Errorf(
				"Expected moduleDirectory to be %s, got %s",
				test.expectedModuleDirectory,
				moduleDirectory,
			)
		}

		if buildContext != test.expectedBuildContext {
			t.Errorf(
				"Expected buildContext to be %s, got %s",
				test.expectedBuildContext,
				buildContext,
			)
		}
	}
}

func TestFindAssemblyName(t *testing.T) {
	assemblyName, _ := findAssemblyName(
		".github/test/src/core-demo-api.csproj",
		"src/core-demo-api.csproj",
		true,
	)
	const expectedAssemblyName = "core-demo-api.dll"

	if assemblyName != expectedAssemblyName {
		t.Errorf(
			"Expected assemblyName to be %s, got %s",
			assemblyName,
			expectedAssemblyName,
		)
	}
}
