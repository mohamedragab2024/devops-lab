# Use the official .NET 6 SDK image as the base image
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build

# Set the working directory in the container
WORKDIR /app

# Copy the .NET 6 project file and restore dependencies
COPY *.csproj ./
RUN dotnet restore

# Copy the entire application source code
COPY . ./

# Build the application
RUN dotnet publish -c Release -o out

# Use the official .NET 6 runtime image as the base image
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS runtime

# Set the working directory in the container
WORKDIR /app

# Copy the built application from the build image
COPY --from=build /app/out ./

# Set the entry point for the container
ENTRYPOINT ["dotnet", "productService.dll"]
