#!/usr/bin/env bash

results=$(sonobuoy retrieve)
sonobuoy e2e $results
