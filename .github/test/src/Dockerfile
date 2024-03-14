FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
LABEL maintainer="elvia@elvia.no"

WORKDIR /app
COPY . .
RUN dotnet restore \
        ./core-demo-api.csproj \
    && dotnet publish \
        ./core-demo-api.csproj \
        --configuration Release \
        --output ./out


FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
LABEL maintainer="elvia@elvia.no"

RUN addgroup application-group --gid 1001 \
    && adduser application-user --uid 1001 \
        --ingroup application-group \
        --disabled-password

WORKDIR /app
EXPOSE 8080
COPY --from=build /app/out .
RUN chown --recursive application-user .
USER application-user
EXPOSE 8080
ENTRYPOINT ["dotnet", "core-demo-api.dll"]
