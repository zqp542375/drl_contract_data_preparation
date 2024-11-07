
import argparse
import logging

from code_tasks.task_evaluation import evaluate_entity_names, \
    evaluate_conditions, evaluate_entity_conditions, \
    evaluate_entity_assignments, evaluate_all_tasks_individually, \
    evaluate_all_tasks_as_a_whole
from code_tasks.task_handle import get_entity_names, get_assignments, \
    get_conditions, get_all_task_data_as_a_whole, get_all_task_data_individually
from code_tasks.task_results_presentation import present_entity_names, \
    present_entity_conditions, present_entity_assignments, \
    present_all_tasks_as_a_whole, present_all_tasks_individually
from config import parameters, dataset_contract_info_path, result_path, \
    dataset_path, contract_index, dataset_solidity_path, contract_data_path, \
    task_data_path
# from contract_data_collection.get_info_from_ast_x import contract_data
# from function_dependency.cli_dependency import dependency
# from function_evaluation.cli_function_evaluation import function_evaluation
from dataset_preparation.get_contract_data import get_contract_data
from dataset_preparation.get_contract_task_data import \
    get_contract_task_data_from_solidity

logger = logging.getLogger(__name__)



def register_basic_arguments(parser: argparse.ArgumentParser):

    parser.add_argument('--solidity_file_name', type=str,
                        default=parameters[contract_index][0])
    parser.add_argument('--contract_name', type=str,
                        default=parameters[contract_index][1])
    parser.add_argument('--solc_version', type=str,
                        default=parameters[contract_index][2])
    parser.add_argument('--log_level', type=int, default=3)

    parser.add_argument('--task', type=str, default="function_dependency",
                        help="specify the task",
                        choices = ['function_dependency', 'task_generation', 'task_evaluation','evaluation_presentation', 'contract_data_preparation','task_data_preparation'])


    parser.add_argument('--dataset_path', type=str, default=dataset_path)
    parser.add_argument('--solidity_file_path', type=str, default=dataset_solidity_path)
    parser.add_argument('--dataset_contract_info_path', type=str,
                        default=dataset_contract_info_path)
    parser.add_argument('--dataset_dependency_path', type=str,
                        default=dataset_path + "/dependency/")
    parser.add_argument('--result_path', type=str, default=result_path)
    parser.add_argument('--contract_data_path', type=str, default=contract_data_path)
    parser.add_argument('--task_data_path', type=str,
                        default=task_data_path)
    return parser




def register_task_based_arguments(parser:argparse.ArgumentParser):

    parser.add_argument('--sub_task', type=str, default="prepare_dataset",
                        choices=['name_detection', 'condition_recognition',
                                 'assignment_identification','all_as_a_whole','all_individually'],
                        help="specify the sub task.")

    return parser

def register_openai_arguments(parser:argparse.ArgumentParser):
    parser.add_argument('--engine', default='gpt-3.5-turbo-0301', choices=[
        "gpt-3.5-turbo-0301"])
    parser.add_argument('--temperature', type=float, default=0.0)
    parser.add_argument('--prompt_id', type=str, default="",
                        help="specify the id of the prompt")
    return parser



def set_logging_level(args):
    if args.log_level==4:
        logging.basicConfig(
            level=logging.DEBUG,  # Set the logging level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
            format='%(asctime)s [%(levelname)s]: %(message)s',  # Define the log message format
            datefmt='%Y-%m-%d %H:%M:%S'  # Define the date-time format
        )
    elif args.log_level==5:
        logging.basicConfig(
            level=logging.ERROR,  # Set the logging level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
            format='%(asctime)s [%(levelname)s]: %(message)s',  # Define the log message format
            datefmt='%Y-%m-%d %H:%M:%S'  # Define the date-time format
        )
    elif args.log_level == 3:
        logging.basicConfig(
            level=logging.WARNING,  # Set the logging level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
            format='%(asctime)s [%(levelname)s]: %(message)s',  # Define the log message format
            datefmt='%Y-%m-%d %H:%M:%S'  # Define the date-time format
        )
    else:
        logging.basicConfig(
            level=logging.INFO,
            # Set the logging level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
            format='%(asctime)s [%(levelname)s]: %(message)s',
            # Define the log message format
            datefmt='%Y-%m-%d %H:%M:%S'  # Define the date-time format
        )


def main():
    # Create an ArgumentParser object
    parser = argparse.ArgumentParser(description="A simple script with command-line arguments.")

    parser = register_basic_arguments(parser)
    parser = register_openai_arguments(parser)
    parser = register_task_based_arguments(parser)
    # Parse the command-line arguments
    args = parser.parse_args()

    set_logging_level(args)

    if args.task == 'function_dependency':
        print("do function_dependency")
    elif args.task == 'task_generation':
        generate_tasks(args)
    elif args.task == 'task_evaluation':
        evaluate_tasks(args)
    elif args.task=='evaluation_presentation':
        present_evaluation_results(args)
    elif args.task == 'task_data_preparation':
        get_contract_task_data_from_solidity(args.solidity_file_path,args.solidity_file_name,args.contract_name,args.solc_version,args.task_data_path)
    elif args.task == 'contract_data_preparation':
        get_contract_data(args.solidity_file_path, args.solidity_file_name, args.contract_name, args.solc_version, args.contract_data_path)
    else:
        print(f'{args.task} is not implemented yet.')
    exit()


def generate_tasks(args):
    if args.sub_task=='name_detection':
        get_entity_names(args.solidity_file_name, args.contract_name,
                         args.contract_data_path, args.result_path)

    elif args.sub_task=='condition_recognition':
        get_conditions(args.solidity_file_name, args.contract_name,
                         args.contract_data_path, args.result_path)

    elif args.sub_task=='assignment_identification':
        get_assignments(args.solidity_file_name, args.contract_name,
                         args.contract_data_path, args.result_path)

    elif args.sub_task == 'all_as_a_whole':
        get_all_task_data_as_a_whole(args.solidity_file_name, args.contract_name,
                                     args.contract_data_path, args.result_path)
    elif args.sub_task == 'all_individually':
        get_all_task_data_individually(args.solidity_file_name,
                                     args.contract_name,
                                     args.contract_data_path, args.result_path)
    else:
        print(f'{args.sub_task} for {args.task} is not implemented yet.')


def evaluate_tasks(args):
    if args.sub_task == 'name_detection':
        evaluate_entity_names(args.solidity_file_name, args.contract_name,
                         args.task_data_path, args.result_path+"generation\\",args.result_path)

    elif args.sub_task == 'condition_recognition':
        evaluate_entity_conditions(args.solidity_file_name, args.contract_name,
                         args.task_data_path, args.result_path+"generation\\",args.result_path)

    elif args.sub_task == 'assignment_identification':
        evaluate_entity_assignments(args.solidity_file_name, args.contract_name,
                         args.task_data_path, args.result_path+"generation\\",args.result_path)

    elif args.sub_task == 'all_as_a_whole':
        evaluate_all_tasks_as_a_whole(args.solidity_file_name, args.contract_name,
                         args.task_data_path, args.result_path+"generation\\",args.result_path)

    elif args.sub_task == 'all_individually':
        evaluate_all_tasks_individually(args.solidity_file_name, args.contract_name,
                         args.task_data_path, args.result_path+"generation\\",args.result_path)
    else:
        print(f'{args.sub_task} for {args.task} is not implemented yet.')

def present_evaluation_results(args):
    if args.sub_task == 'name_detection':
        present_entity_names(args.solidity_file_name, args.contract_name,
                              args.result_path + "evaluation\\"
                              )

    elif args.sub_task == 'condition_recognition':
        present_entity_conditions(args.solidity_file_name, args.contract_name,
                              args.result_path + "evaluation\\")

    elif args.sub_task == 'assignment_identification':
        present_entity_assignments(args.solidity_file_name, args.contract_name,
                              args.result_path + "evaluation\\")

    elif args.sub_task == 'all_as_a_whole':
        present_all_tasks_as_a_whole(args.solidity_file_name, args.contract_name,
                              args.result_path + "evaluation\\")

    elif args.sub_task == 'all_individually':
        present_all_tasks_individually(args.solidity_file_name, args.contract_name,
                              args.result_path + "evaluation\\")
    else:
        print(f'{args.sub_task} for {args.task} is not implemented yet.')

if __name__=="__main__":
    main()



