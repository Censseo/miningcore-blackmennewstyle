@echo off
cd src\Miningcore
dotnet publish -c Release --framework net7.0 -o ../../build
