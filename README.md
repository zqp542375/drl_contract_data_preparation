The repository is for collecting contract data that will be used used to construct the path-finding game for project [Segen](https://github.com/zqp542375/drl_segen.git).


**Assume that**:
- Slither is available to collect the static analysis data (having installed all the packages in requirements.txt is sufficient).
- The symbolic execution traces of each contract are available.

To collect data for the small dataset:
```
run rl_small_dataset_data_preparation.py
```

Collect data for the sGuard dataset:

```
run rl_sGuard_data_preparation.py
```

The steps of how to collect data are explicitly given in the above two files.

All the files generated are saved in "./results/rl_related" directory.

The json file name with suffix "_integer" is the final contract data files that are used in Segen.
