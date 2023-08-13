# kubefwd Relabeler

Helm chart that automatically watch and add `kubefwd: true`
labels to services with `kubefwd: true` annotation
or services that matches certain names.

This is used for development, allowing kubefwd to only forward
services with `kubefwd: true` labels if chart's don't allow you to
override labels on services.
