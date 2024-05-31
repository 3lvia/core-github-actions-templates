import os
import uuid
import xml.etree.ElementTree as ET


def find_assembly_name(csproj_file):
    root = ET.parse(csproj_file).getroot()
    if len(root.findall("PropertyGroup/AssemblyName")) > 0:
        return root.findall("PropertyGroup/AssemblyName")[-1].text + ".dll"
    else:
        return os.path.dirname(csproj_file) + ".dll"


def find_docker_base_image_tag(csproj_file):
    root = ET.parse(csproj_file).getroot()
    if len(root.findall("PropertyGroup/TargetFramework")) > 0:
        framework = root.findall("PropertyGroup/TargetFramework")[-1].text # net8.0
        tag = framework[3:] + "-alpine"
        return tag
    else:
        raise ValueError("Unable to find TargetFramework in csproj-file")


def write_dockerfile(csproj_file, assembly_name, docker_base_image_tag, filename):
    with open(os.environ["GITHUB_OUTPUT"], "a") as fh:
        key = "DOCKERFILE"
        print(f"{key}={filename}", file=fh)

    template = """FROM mcr.microsoft.com/dotnet/sdk:{docker_base_image_tag} AS build
LABEL maintainer="elvia@elvia.no"
WORKDIR /app
COPY . .
RUN dotnet restore \\
        {csproj_file} \\
    && dotnet publish \\
        {csproj_file} \\
        --configuration Release \\
        --output ./out

FROM mcr.microsoft.com/dotnet/aspnet:{docker_base_image_tag} AS runtime
LABEL maintainer="elvia@elvia.no"
RUN addgroup application-group --gid 1001 \\
    && adduser application-user --uid 1001 \\
        --ingroup application-group \\
        --disabled-password

RUN apk upgrade --no-cache

WORKDIR /app
COPY --from=build /app/out .
RUN chown --recursive application-user .
USER application-user
EXPOSE 8080
ENTRYPOINT ["dotnet", "{assembly_name}"]
"""
    context = {"csproj_file": csproj_file, "assembly_name": assembly_name, "docker_base_image_tag": docker_base_image_tag}
    with open(filename, "w") as f:
        f.write(template.format(**context))

    f = open(filename, "a")
    f.write(
        """
"""
    )
    f.close()

    f = open(filename, "r")
    print("Dockerfile:\n" + f.read())


def main():
    csproj_file = os.environ.get("CSPROJ_FILE")
    if csproj_file == None:
        raise ValueError("Missing required Environment Variable CSPROJ_FILE")
    print("csproj_file: " + csproj_file)

    directory = os.path.join("tmp", str(uuid.uuid4()))
    os.makedirs(directory)
    filename = os.path.join(directory, "Dockerfile")
    print("filename: " + filename)

    assembly_name = find_assembly_name(csproj_file)
    print(assembly_name)
    docker_base_image_tag = find_docker_base_image_tag(csproj_file)
    print(docker_base_image_tag)
    # raise ValueError("Q")
    write_dockerfile(csproj_file, assembly_name, docker_base_image_tag, filename)


if __name__ == "__main__":
    main()
