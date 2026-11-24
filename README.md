# PayLink

PayLink - Digital Wallet and Bill Payment System (CS352 Advanced Software Engineering project).

## Requirements

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (to run the API and database)
- [.NET 9 SDK](https://dotnet.microsoft.com/download/dotnet/9.0) (to build, test and format the code locally)

## Run the system

From a clean clone:

```bash
docker compose up --build
```

This starts two containers:

| Container | What it is | Address |
|---|---|---|
| `paylink-api` | The PayLink API | http://localhost:8080 |
| `paylink-database` | SQL Server 2022 (Developer edition) | `localhost,1433`, user `sa` |

The API waits until the database passes its health check, which can take up to a minute on the first start. When it is up, http://localhost:8080 returns `Hello World!`.

Stop everything with `docker compose down`. Add `-v` to also delete the database volume.

### Database password

`docker-compose.yml` uses a development default password, so a clean clone starts with no extra setup. To use your own, copy `.env.example` to `.env` and change `MSSQL_SA_PASSWORD`. SQL Server requires at least 8 characters with upper case, lower case, a digit and a symbol. `.env` is ignored by Git; never commit a real password.

## Build, test and format

```bash
dotnet restore PayLink.sln
dotnet build PayLink.sln
dotnet test PayLink.sln
dotnet format PayLink.sln --verify-no-changes --no-restore
```

The last command fails if any file is not formatted. Run `dotnet format PayLink.sln` to fix the files, then commit them.

## Continuous integration

`.github/workflows/ci.yml` runs on every push and on pull requests to `main`, in two jobs:

1. **build-and-test:** restore, format check, build, and tests.
2. **docker-smoke-test:** runs `docker compose up --build --wait` from a clean checkout, checks that http://localhost:8080 answers, then stops the containers.

A pull request should only be merged when both jobs are green.

## Repository structure

| Path | Contents |
|---|---|
| `src/PayLink.Api` | The ASP.NET Core API |
| `tests/PayLink.Tests` | xUnit tests |
| `docs/design` | Design diagrams (Mermaid sources and exported PNGs) |
| `docs/prompt-log.md` | Log of every AI tool use (brief section 6) |
| `Dockerfile`, `docker-compose.yml` | Container build and local environment |
