#!/bin/bash

cd layer-participant
terraform destroy -auto-approve
cd -

cd layer-base
terraform destroy -auto-approve
cd -
