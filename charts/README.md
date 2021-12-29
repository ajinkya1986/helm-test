# Cloudanix Container Protection Helm Chart

This Helm chart helps to install multiple Cloudanix services for container protection. The following services are installed

- cloudanix-informer
- falco-sidekick
- config-cron

## Falco Chart

The chart also installs the Falco community chart which is added as a dependency in Chart.yaml. 


## Usage

Clone this repository and in `chart` folder, update the `yourValues.yaml` to override the values.
To install the chart, run

```
helm dependency update
helm install cloudanix -f yourValues.yaml .
```


To delete the chart, run 
```
helm delete cloudanix
```
