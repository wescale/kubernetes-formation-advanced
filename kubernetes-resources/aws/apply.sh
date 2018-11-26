#!/bin/bash

cd layer-base
terraform apply
cd -

cd layer-participant
terraform apply
cd -