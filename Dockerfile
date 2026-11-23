
# Build stage
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build

WORKDIR /src

COPY src/PayLink.Api/PayLink.Api.csproj src/PayLink.Api/

RUN dotnet restore src/PayLink.Api/PayLink.Api.csproj

COPY . .

RUN dotnet publish src/PayLink.Api/PayLink.Api.csproj \
    -c Release \
    -o /app/publish \
    --no-restore

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final

WORKDIR /app

COPY --from=build /app/publish .

ENV ASPNETCORE_HTTP_PORTS=8080

EXPOSE 8080

ENTRYPOINT ["dotnet", "PayLink.Api.dll"]
