# OpenEverest Homebrew Tap

Homebrew tap for `everestctl` - the OpenEverest CLI tool for managing OpenEverest on Kubernetes.

## Installation

```bash
brew tap openeverest/tap
brew install everestctl
```

## Usage

### Install OpenEverest

Install with wizard (interactive):
```bash
everestctl install
```

Install without wizard (headless):
```bash
everestctl install --namespaces <namespace-name> --operator.mongodb=true --operator.postgresql=true --operator.mysql=true --skip-wizard
```

### Common Commands

Add a namespace:
```bash
everestctl namespaces add <NAMESPACE>
```

Skip database namespace during installation:
```bash
everestctl install --skip-db-namespace
```

Update admin password:
```bash
everestctl accounts set-password --username admin
```

## Documentation

For detailed installation and usage instructions, see the [everestctl installation documentation](https://openeverest.io/documentation/current).
