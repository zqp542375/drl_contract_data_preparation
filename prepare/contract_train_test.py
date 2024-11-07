# -*- coding: utf-8 -*-
"""
July 4th, 2024
adapted from classify_contracts_sGuard.py

map functions to integers and different vector presentations
classify contracts: training and testing sets

"""



from prepare.config import contract_data_for_env_construction_in_integer, rl_result_path
from prepare.utils import get_key_from_list, get_seq_from_key, \
    find_minimum_covering_lists, dump_json_object_to_json

"""
For the contracts collected based on sGaurd dataset:
    having at least three functions write a non-constant state variables
    have at least two contracts in a category when contracts are organized by state variables
    having both start functions and targets  

divide the contracts into the training set and testing set

"""




def group_contracts_map_functions(contracts_data: dict):
    """

    functions are identified by the name and the rw (in rw format)
    so functions having the same from the same contract or different contracts are not mapped to
    a different value if the rw are different.
    """
    contracts_by_svar = {}
    for con_key, data in contracts_data.items():
        if ".sol" not in con_key: continue

        svar_selected = data['state_variables_selected']
        key_svar = get_key_from_list(svar_selected)
        if key_svar not in contracts_by_svar.keys():
            contracts_by_svar[key_svar] = [con_key]
        else:
            if con_key not in contracts_by_svar[key_svar]:
                contracts_by_svar[key_svar].append(con_key)

    # =========================
    # assign an integer values to functions for each group
    # filter functions that have no writes except for the constructor() as they can not change the states.
    contract_function_to_int_by_svar = {}
    contract_possible_targets = {}
    for key_svar, contract_keys in contracts_by_svar.items():
        function_to_int = {}
        int_to_function = {}
        int_to_full_function_name = {}
        int_key = 0
        # --------------debug start--------------
        # flag=False
        # for con_key in contract_keys:
        #     if con_key in test_data:
        #         flag=True
        #         break
        # if not flag:
        #     continue

        # flag=False
        # for con_key in contract_keys:
        #     if con_key in ['0x002c97933d0976dbcf51c0e8f8a3e64d8fd9d296.solIranMoney']:
        #
        #         flag=True
        #         break
        # if not flag:
        #     continue

        # flag = False
        # for con_key in contract_keys:
        #     if con_key in ['0x002c97933d0976dbcf51c0e8f8a3e64d8fd9d296.solIranMoney']:
        #         flag = True
        #         break
        # if not flag:
        #     continue

        # --------------debug end--------------

        for con_key in contract_keys:
            data = contracts_data[con_key]
            function_data = data['function_data']

            # functions appearing in sequences at indices > 1
            func_in_sequences_not_the_first_function = []
            for seq_key, _ in data["function_sequences"].items():
                if '#' in seq_key:
                    seq = get_seq_from_key(seq_key)
                    for func in seq[1:]:
                        if func not in func_in_sequences_not_the_first_function:
                            func_in_sequences_not_the_first_function.append(
                                func)

            contract_possible_targets[
                con_key] = func_in_sequences_not_the_first_function

            pure_names_to_full_names = {}
            for name, func_data in function_data.items():
                if func_data["pure_name"] in ['constructor']: continue
                if len(func_data['writes']) == 0:
                    if func_data[
                        "pure_name"] not in func_in_sequences_not_the_first_function:
                        continue

                if func_data[
                    "pure_name"] not in pure_names_to_full_names.keys():
                    pure_names_to_full_names[func_data["pure_name"]] = [
                        func_data['name']]
                else:
                    pure_names_to_full_names[func_data["pure_name"]] += [
                        func_data['name']]

            considered_function_full_names = []
            for pure_name, full_name_list in pure_names_to_full_names.items():
                if len(full_name_list) == 1:
                    considered_function_full_names.append(full_name_list[0])
                else:
                    target_full_name = ''
                    max_rw_c = 0
                    for full_name in full_name_list:
                        func_data = data['function_data'][full_name]
                        rw_c = len(func_data['reads']) + len(
                            func_data['writes'])
                        if rw_c > max_rw_c:
                            max_rw_c = rw_c
                            target_full_name = full_name
                    considered_function_full_names.append(target_full_name)

            for name, func_data in function_data.items():

                if func_data["pure_name"] in ['constructor']: continue
                # if func_data["pure_name"] not in pure_names_to_full_names.keys():continue

                if name not in considered_function_full_names: continue
                func_key = f'{func_data["pure_name"]},{get_key_from_list(func_data["vector_rw_in_concate"])}'
                if func_key not in function_to_int.keys():
                    int_key += 1
                    function_to_int[func_key] = int_key
                    int_to_function[int_key] = func_key
                    int_to_full_function_name[int_key] = func_data["name"]

        contract_function_to_int_by_svar[key_svar] = {
            'function_to_int': function_to_int,
            'int_to_function': int_to_function,
            "int_to_full_function_name": int_to_full_function_name}
    return contract_function_to_int_by_svar, contracts_by_svar, contract_possible_targets


def group_contracts_map_functions_1(contracts_data: dict):
    """

    functions are identified by the name and the rw (in rw format)
    so functions having the same from the same contract or different contracts are not mapped to
    a different value if the rw are different.
    """
    contract_functions_to_integers={}
    contracts_by_svar_func = {}
    for con_key, data in contracts_data.items():
        if ".sol" not in con_key: continue

        svar_selected = data['state_variables_selected']
        functions_identifer=data["function_value"]
        key_svar_func = get_key_from_list(svar_selected+functions_identifer)
        if key_svar_func not in contracts_by_svar_func.keys():
            contracts_by_svar_func[key_svar_func] = [con_key]
        else:
            if con_key not in contracts_by_svar_func[key_svar_func]:
                contracts_by_svar_func[key_svar_func].append(con_key)

    # =========================
    # assign an integer values to functions for each group
    # filter functions that have no writes except for the constructor() as they can not change the states.
    contract_function_to_int_by_svar_func = {}
    contract_possible_targets = {}
    for key_svar_func, contract_keys in contracts_by_svar_func.items():
        function_to_int = {}
        int_to_function = {}
        int_to_full_function_name = {}
        int_key = 0

        for con_key in contract_keys:
            data = contracts_data[con_key]
            function_data = data['function_data']

            # functions appearing in sequences at indices > 1
            func_in_sequences_not_the_first_function = []
            for seq_key, _ in data["function_sequences"].items():
                if '#' in seq_key:
                    seq = get_seq_from_key(seq_key)
                    for func in seq[1:]:
                        if func not in func_in_sequences_not_the_first_function:
                            func_in_sequences_not_the_first_function.append(
                                func)

            contract_possible_targets[
                con_key] = func_in_sequences_not_the_first_function

            pure_names_to_full_names = {}
            for name, func_data in function_data.items():
                if func_data["pure_name"] in ['constructor']: continue
                if len(func_data['writes']) == 0:
                    if func_data[
                        "pure_name"] not in func_in_sequences_not_the_first_function:
                        # ignore the functions having no writes and not appearing in sequences.
                        continue

                if func_data[
                    "pure_name"] not in pure_names_to_full_names.keys():
                    pure_names_to_full_names[func_data["pure_name"]] = [
                        func_data['name']]
                else:
                    pure_names_to_full_names[func_data["pure_name"]] += [
                        func_data['name']]

            # there are cases, multiple functions having the same full name
            # find unique full names
            considered_function_full_names = []
            for pure_name, full_name_list in pure_names_to_full_names.items():
                if len(full_name_list) == 1:
                    considered_function_full_names.append(full_name_list[0])
                else:
                    target_full_name = ''
                    max_rw_c = 0
                    for full_name in full_name_list:
                        func_data = data['function_data'][full_name]
                        rw_c = len(func_data['reads']) + len(
                            func_data['writes'])
                        if rw_c > max_rw_c:
                            max_rw_c = rw_c
                            target_full_name = full_name
                    considered_function_full_names.append(target_full_name)

            # map functions to integers
            for name, func_data in function_data.items():
                if func_data["pure_name"] in ['constructor']: continue
                # if func_data["pure_name"] not in pure_names_to_full_names.keys():continue

                if name not in considered_function_full_names: continue

                func_key = f'{func_data["pure_name"]},{get_key_from_list(func_data["vector_rw_in_concate"])}'
                if func_key not in function_to_int.keys():
                    int_key += 1
                    function_to_int[func_key] = int_key
                    int_to_function[int_key] = func_key
                    int_to_full_function_name[int_key] = func_data["name"]

        contract_function_to_int_by_svar_func[key_svar_func] = {
            'function_to_int': function_to_int,
            'int_to_function': int_to_function,
            "int_to_full_function_name": int_to_full_function_name}
    return contract_function_to_int_by_svar_func, contracts_by_svar_func, contract_possible_targets





def update_contract_data_in_integer(old_contracts_data: dict):
    contract_function_to_int_by_svar, contract_by_svar, contract_possible_targets = group_contracts_map_functions(
        old_contracts_data)
    contracts_data_update_in_integer = {}
    contracts_having_no_targets_2 = []
    for con_key, data in old_contracts_data.items():
        if '.sol' not in con_key: continue
        """
        data={
            "state_variable": self.envDataCollected.state_variables,         
            "state_variables_in_integer":self.state_variables_in_integer,
            "state_variables_selected":self.selected_svar, # select 8 state variables
            "function_value":self.function_value,
            "function_value_n0":self.function_value_n0,
            "function_data":self.function_data,
            "function_sequences":self.envDataCollected.function_sequence_writes,
            "functions_in_sequences":self.envDataCollected.functions_in_sequences,
            "target_functions":self.envDataCollected.targets,
            "start_functions":self.envDataCollected.start_functions            
            }
        """

        svar_selected = data['state_variables_selected']
        key_svar = get_key_from_list(svar_selected)
        function_int_data = contract_function_to_int_by_svar[key_svar]

        func_pure_name_to_int = {}
        int_to_func_pure_name = {}
        function_data_with_int_key = {}

        for func_name, func_data in data['function_data'].items():
            if func_data["pure_name"] in ['constructor']: continue
            # if len(func_data['writes']) == 0: continue
            func_key = f'{func_data["pure_name"]},{get_key_from_list(func_data["vector_rw_in_concate"])}'

            # ignore the functions that are not mapped due to having the same function names as other mapped functions
            if func_key not in function_int_data[
                'function_to_int'].keys(): continue
            int_key = int(function_int_data['function_to_int'][func_key])
            func_data['int_key'] = int_key
            func_data['func_key'] = func_key

            func_pure_name_to_int[func_data["pure_name"]] = int_key
            int_to_func_pure_name[int_key] = func_data["pure_name"]

            function_data_with_int_key[int_key] = func_data

        # get function sequences in integer
        sequences_in_int = []
        sequence_writes = {}
        for key, writes in data['function_sequences'].items():
            if key == 'constructor':
                continue
            func_seq = get_seq_from_key(key)
            func_seq_int = []
            for func in func_seq:
                if func not in func_pure_name_to_int.keys():
                    func_seq_int = []
                    break
                else:
                    func_seq_int.append(func_pure_name_to_int[func])
            if len(func_seq_int) > 0:
                sequences_in_int.append(func_seq_int)
                new_key = get_key_from_list(func_seq_int)
                sequence_writes[new_key] = writes

        targets = []
        starts = []
        for func in data['target_functions']:
            if func not in contract_possible_targets[con_key]: continue
            if func in func_pure_name_to_int.keys():
                int_value = func_pure_name_to_int[func]
                targets.append(int_value)

        if len(targets) == 0:
            contracts_having_no_targets_2.append(con_key)
            continue

        for func in data['start_functions']:
            if func in func_pure_name_to_int.keys():
                int_value = func_pure_name_to_int[func]
                starts.append(int_value)

        func_in_seq_in_integer = []
        for func in data["functions_in_sequences"]:
            if func in func_pure_name_to_int.keys():
                func_in_seq_in_integer.append(func_pure_name_to_int[func])
        possible_targets_in_integer = []
        for item in contract_possible_targets[con_key]:
            if item in func_pure_name_to_int.keys():
                possible_targets_in_integer.append(func_pure_name_to_int[item])

        contracts_data_update_in_integer[con_key] = {
            "state_variable": data["state_variable"],
            "state_variables_in_integer": data["state_variables_in_integer"],
            "state_variables_selected": data["state_variables_selected"],
            # select 8 state variables
            "function_value": data["function_value"],
            "function_value_n0": data["function_value_n0"],
            "function_data": function_data_with_int_key,
            "func_pure_name_to_int": func_pure_name_to_int,
            "int_to_func_pure_name": int_to_func_pure_name,
            "function_sequences": data["function_sequences"],
            "function_sequences_in_integer": sequences_in_int,
            "possible_targets": contract_possible_targets[con_key],
            # the functions in collected function sequences that appears at positions larger than 0
            "possible_targets_in_integer": possible_targets_in_integer,
            "sequence_writes": sequence_writes,
            # the writes from symbolic execution not static analysis（careful)
            "functions_in_sequences": data["functions_in_sequences"],
            "functions_in_sequences_in_integer": func_in_seq_in_integer,
            "target_functions": data["target_functions"],
            "start_functions": data["start_functions"],
            "target_functions_in_integer": targets,
            "start_functions_in_integer": starts
        }

    contracts_data_update_in_integer[
        "contract_function_to_int_by_svar"] = contract_function_to_int_by_svar
    contracts_data_update_in_integer["contract_by_svar"] = contract_by_svar

    # add additional information:
    contracts_data_update_in_integer['svar_by_type'] = old_contracts_data[
        'svar_by_type']
    contracts_data_update_in_integer['svar_to_int'] = old_contracts_data[
        'svar_to_int']
    contracts_data_update_in_integer['int_to_svar'] = old_contracts_data[
        'int_to_svar']

    dump_json_object_to_json(contracts_data_update_in_integer,
                             f'{rl_result_path}{contract_data_for_env_construction_in_integer}')

    return contracts_having_no_targets_2


def update_contract_data_in_integer_1(old_contracts_data: dict):
    """
    July 14th, 2024
    assign integers to functions xxx
    :param old_contracts_data:
    :return:
    """

    contract_function_to_int_by_svar_func, contract_by_svar_func, contract_possible_targets = group_contracts_map_functions_1(
        old_contracts_data)

    contracts_data_update_in_integer = {}
    contracts_having_no_targets_2 = []
    for con_key, data in old_contracts_data.items():
        if '.sol' not in con_key: continue
        """
        data={
            "state_variable": self.envDataCollected.state_variables,         
            "state_variables_in_integer":self.state_variables_in_integer,
            "state_variables_selected":self.selected_svar, # select 8 state variables
            "function_value":self.function_value,
            "function_value_n0":self.function_value_n0,
            "function_data":self.function_data,
            "function_sequences":self.envDataCollected.function_sequence_writes,
            "functions_in_sequences":self.envDataCollected.functions_in_sequences,
            "target_functions":self.envDataCollected.targets,
            "start_functions":self.envDataCollected.start_functions            
            }
        """

        svar_selected = data['state_variables_selected']
        functions_identifer = data["function_value"]
        key_svar_func = get_key_from_list(svar_selected + functions_identifer)

        function_int_data = contract_function_to_int_by_svar_func[key_svar_func]

        func_pure_name_to_int = {}
        int_to_func_pure_name = {}
        function_data_with_int_key = {}

        for func_name, func_data in data['function_data'].items():
            if func_data["pure_name"] in ['constructor']: continue
            # if len(func_data['writes']) == 0: continue
            func_key = f'{func_data["pure_name"]},{get_key_from_list(func_data["vector_rw_in_concate"])}'

            # ignore the functions that are not mapped due to having the same function names as other mapped functions
            if func_key not in function_int_data[
                'function_to_int'].keys(): continue
            int_key = int(function_int_data['function_to_int'][func_key])
            func_data['int_key'] = int_key
            func_data['func_key'] = func_key

            func_pure_name_to_int[func_data["pure_name"]] = int_key
            int_to_func_pure_name[int_key] = func_data["pure_name"]

            function_data_with_int_key[int_key] = func_data

        # get function sequences in integer
        sequences_in_int = []
        sequence_writes = {}
        for key, writes in data['function_sequences'].items():
            if key == 'constructor':
                continue
            func_seq = get_seq_from_key(key)
            func_seq_int = []
            for func in func_seq:
                if func not in func_pure_name_to_int.keys():
                    func_seq_int = []
                    break
                else:
                    func_seq_int.append(func_pure_name_to_int[func])
            if len(func_seq_int) > 0:
                sequences_in_int.append(func_seq_int)
                new_key = get_key_from_list(func_seq_int)
                sequence_writes[new_key] = writes

        targets = []
        starts = []
        for func in data['target_functions']:
            if func not in contract_possible_targets[con_key]: continue
            if func in func_pure_name_to_int.keys():
                int_value = func_pure_name_to_int[func]
                targets.append(int_value)

        if len(targets) == 0:
            contracts_having_no_targets_2.append(con_key)
            continue

        for func in data['start_functions']:
            if func in func_pure_name_to_int.keys():
                int_value = func_pure_name_to_int[func]
                starts.append(int_value)

        func_in_seq_in_integer = []
        for func in data["functions_in_sequences"]:
            if func in func_pure_name_to_int.keys():
                func_in_seq_in_integer.append(func_pure_name_to_int[func])
        possible_targets_in_integer = []
        for item in contract_possible_targets[con_key]:
            if item in func_pure_name_to_int.keys():
                possible_targets_in_integer.append(func_pure_name_to_int[item])

        contracts_data_update_in_integer[con_key] = {
            "state_variable": data["state_variable"],
            "state_variables_in_integer": data["state_variables_in_integer"],
            "state_variables_selected": data["state_variables_selected"],
            # select 8 state variables
            "function_value": data["function_value"],
            "function_value_n0": data["function_value_n0"],
            "function_data": function_data_with_int_key,
            "func_pure_name_to_int": func_pure_name_to_int,
            "int_to_func_pure_name": int_to_func_pure_name,
            "function_sequences": data["function_sequences"],
            "function_sequences_in_integer": sequences_in_int,
            "possible_targets": contract_possible_targets[con_key],
            # the functions in collected function sequences that appears at positions larger than 0
            "possible_targets_in_integer": possible_targets_in_integer,
            "sequence_writes": sequence_writes,
            # the writes from symbolic execution not static analysis（careful)
            "functions_in_sequences": data["functions_in_sequences"],
            "functions_in_sequences_in_integer": func_in_seq_in_integer,
            "target_functions": data["target_functions"],
            "start_functions": data["start_functions"],
            "target_functions_in_integer": targets,
            "start_functions_in_integer": starts
        }

    contracts_data_update_in_integer[
        "contract_function_to_int_by_svar_func"] = contract_function_to_int_by_svar_func
    contracts_data_update_in_integer["contract_by_svar_func"] = contract_by_svar_func

    # add additional information:
    contracts_data_update_in_integer['svar_by_type'] = old_contracts_data[
        'svar_by_type']
    contracts_data_update_in_integer['svar_to_int'] = old_contracts_data[
        'svar_to_int']
    contracts_data_update_in_integer['int_to_svar'] = old_contracts_data[
        'int_to_svar']

    dump_json_object_to_json(contracts_data_update_in_integer,
                             f'{rl_result_path}{contract_data_for_env_construction_in_integer}')

    return contracts_having_no_targets_2



def divide_contracts(update_contract_data: dict):
    train = []
    test = []
    if "contract_function_to_int_by_svar" in update_contract_data.keys():
        contract_function_to_int_by_svar = update_contract_data[
            "contract_function_to_int_by_svar"]
    else:
        contract_function_to_int_by_svar = update_contract_data[
            "contract_function_to_int_by_svar_func"]

    if "contract_by_svar" in update_contract_data.keys():
        contract_by_svar = update_contract_data["contract_by_svar"]
    else:
        contract_by_svar = update_contract_data["contract_by_svar_func"]

    for key_svar, contract_keys in contract_by_svar.items():
        function_int_data = contract_function_to_int_by_svar[key_svar]
        group_keys = list(function_int_data['int_to_function'].keys())

        # flag=False
        # for con_key in contract_keys:
        #     if con_key in test_data:
        #         flag=True
        #         break
        # if not flag:
        #     continue
        contract_keys = [key for key in contract_keys if
                         key in update_contract_data.keys()]
        if len(contract_keys) == 1:
            train.append(contract_keys[0])
        else:
            # when there are two more contracts in a group, select contracgts either for training or testing

            for_train = []
            for_test = []

            cont_keys__functions = [[con_key, list(
                update_contract_data[con_key]["function_data"].keys())] for
                                    con_key in contract_keys]

            cont_keys__functions_min = find_minimum_covering_lists(
                cont_keys__functions, set(group_keys), on_index=1)
            for con_key, _ in cont_keys__functions_min:
                for_train.append(con_key)
            for con_key, _ in cont_keys__functions:
                if con_key not in for_train:
                    for_test.append(con_key)
            train += for_train
            test += for_test

    return train, test


