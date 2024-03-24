Template VM can be build like that, you just need to create a configuration file, so the variables in the template file get proper values:
```asm
packer build --var-file configuration.json templates/archlinux-x86_64.json
```
