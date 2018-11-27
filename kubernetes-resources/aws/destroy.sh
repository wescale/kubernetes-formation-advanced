#!/bin/bash

cd layer-participant
terraform destroy
cd -

cd layer-base
terraform destroy
cd -
