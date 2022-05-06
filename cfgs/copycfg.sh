#!/bin/bash

mkdir ~/util/cfgs/docker/
cp ~/gotit/docker-compose.yml ~/util/cfgs/docker/docker-compose.yml
cp ~/gotit/mongo/Dockerfile ~/util/cfgs/docker/Dockerfile_mongo
cp ~/gotit/netapi/Dockerfile ~/util/cfgs/docker/Dockerfile_net
cp ~/gotit/react/Dockerfile ~/util/cfgs/docker/Dockerfile_react

mkdir ~/util/cfgs/mongo/
cp ~/gotit/mongo/mongod.conf ~/util/cfgs/mongo/mongod.conf

mkdir ~/util/cfgs/netapi
cp ~/gotit/netapi/appsettings.json ~/util/cfgs/netapi/appsettings._json
cp ~/gotit/netapi/netapi.csproj ~/util/cfgs/netapi/netapi._csproj
cp ~/gotit/netapi/NLog.config ~/util/cfgs/netapi/NLog._config
cp ~/gotit/netapi/Startup.cs ~/util/cfgs/netapi/Startup._cs
cp ~/gotit/netapi/Properties/launchSettings.json ~/util/cfgs/netapi/launchSettings._json
  
mkdir ~/util/cfgs/react
cp ~/gotit/react/.babelrc ~/util/cfgs/react/.babelrc
cp ~/gotit/react/.eslintrc.js ~/util/cfgs/react/.eslintrc._js
cp ~/gotit/react/.prettierrc ~/util/cfgs/react/.prettierrc
cp ~/gotit/react/index.d.ts ~/util/cfgs/react/index.d._ts
cp ~/gotit/react/package.json ~/util/cfgs/react/package._json
cp ~/gotit/react/sett.env ~/util/cfgs/react/sett._env
cp ~/gotit/react/tsconfig.json ~/util/cfgs/react/tsconfig._json
cp ~/gotit/react/webpack.config.ts ~/util/cfgs/react/webpack.config._ts