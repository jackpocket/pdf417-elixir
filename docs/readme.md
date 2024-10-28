# jackpocket-ops-protobuf
Protobuf IDL for Operations

## Setup
`sudo apt install protobuf-compiler=25.4`(Linux) or `brew install protobuf@25.4`(Mac)
`mix escript.install hex protobuf`

## Generating pb files for Elixir
`cd proto_builder_ex`
`./generate.sh`

This will create pb files in the output directory

## Generating pb files for Ruby
`cd proto_builder_rb`
`./generate.sh`

This will create pb files in the output directory

## Generating pb files for Java
`cd proto_builder_java`
`./generate.sh`

This will create pb files in the output directory

## Publishing new libraries

### Adding new protobuf definitions
The pom.xml file will need to be edited to add any new protobuf definitions to be published to Confluent Schema Registry. There are two areas of the file that need to be modified, the validate and register sections. Both will require full paths to the new protobuf files as well as a reference definition if the added protobuf imports other protobuf files.

### For Elixir
`cd proto_builder_ex/proto`
Update the version in `mix.exs`
`mix publish`
- This is an alias that cleans out previously generated code,
- regenerates the protobuf files,
- and publishes to our private Hex org

### For Java
`cd proto_builder_java/proto`
Update the version in `build.gradle`
tagging with java-vX.X.X will then publish to our private maven repo


### Linter
We use [protolint](https://github.com/yoheimuta/protolint). You can install it with:

```
npm i -g protolint
```

And run:

```
protolint lint .
```

## Troubleshoot

If the CI build is failing, try making sure your local protoc version is 25.4.

e.g. in Linux

```
 $ protoc --version
libprotoc 25.4
```

To download the correct version e.g.

```
PB_REL="https://github.com/protocolbuffers/protobuf/releases"
wget $PB_REL/download/v25.4/protoc-25.4-linux-x86_64.zip
unzip protoc-25.4-linux-x86_64.zip -d $HOME/.local
```
