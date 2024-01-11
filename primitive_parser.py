import re
import argparse
import glob
import subprocess
import os
import shutil



def check_release(directory_path):
    if not os.path.exists(directory_path):
        print(f"Error: Path '{directory_path}' does not exist in the release.")
        return False
    else:
        return True


def extract_file_paths(directory_path):

#    directory_path = "/home/users/bilal.ahmed/interconnect/primitves/sw_sim-0.5.6/device_modeling/models_internal/verilog"
    file_pattern = "*.v"

    model_list = glob.glob(f"{directory_path}/{file_pattern}", recursive=True)

#    print(model_list, len(model_list), "model lists here")
    return model_list


def extract_names(model_list):
    prim_verilog_list = [path.split('/')[-1] for path in model_list]

#    print(prim_verilog_list)

    prim_name_list = [name[:-2] if name.endswith('.v') else name for name in prim_verilog_list]

    print(prim_name_list)
    return prim_name_list


def different_primitves(src, model_list):    
    directory_path = src
#    print("------------------9999999999999------------------",directory_path)
    # Initialize an empty list to store folder names
    dest_prim_names = []

    # Iterate over items in the specified directory
    for item in os.listdir(directory_path):
        item_path = os.path.join(directory_path, item)
        if os.path.isdir(item_path):
            dest_prim_names.append(item)
    print("dest_prim_names", dest_prim_names)

    dest_prim_set = set(dest_prim_names)
    src_prim_set = set(model_list)
    result = dest_prim_set - src_prim_set
    print("------result ------------------", result)
    return list(result)

def check_git_diff(filepath, module_name):
#    diff_result = subprocess.check_output(["git", "diff", "--name-status", f"'./{module_name}*.v'", filepath], text=True, shell=True)
    diff_result = subprocess.check_output(["git", "diff", filepath], text=True)
    print("Diff done")

    if not diff_result.strip():
        print("Files are same")
        diff_Status = False
    else:
        print("Files are different")
        diff_Status = True
    return diff_Status,diff_result


def copy_module_files(src_path, dest_path, module_name):

#    print("copy_dest_Path", dest_path)
#    os.makedirs(os.path.join(dest_path, module_name, "blackbox"), exist_ok=True)
#    os.makedirs(os.path.join(dest_path, module_name, "src"), exist_ok=True)
#    os.makedirs(os.path.join(dest_path, module_name, "tb"), exist_ok=True)

    src_file = os.path.join(src_path, f"{module_name}.v")
    dest_file = os.path.join(dest_path, f"{module_name}.v")

#    print("src_file",src_file ,"dest_file", dest_file)

    shutil.copyfile(src_file, dest_file)


def parse_primitves(file_path1,file_path2):
    
    module_a_code = extract_module_code(file_path1)
    module_b_code = extract_module_code(file_path2)
    
#    print(module_a_code)
    param_list_a = []
    port_list_a = []
    param_list_b = []
    port_list_b = []

    param_list_a = extract_module_params(module_a_code)
    param_list_b = extract_module_params(module_b_code)

    port_list_a = extract_module_ports(module_a_code)
    port_list_b = extract_module_ports(module_b_code)


    # Extracted ports and parameters for Module A and Module B
    ports_module_a = set(port_list_a)
    params_module_a = set(param_list_a)
    ports_module_b =  set(port_list_b)
    params_module_b = set(param_list_b)

#    print("\n---------------------------Comparison here--------------------------------------------\n")

    myset1 = {'CLK', 'UNSIGNED_A', 'A', 'Z', 'SATURATE_ENABLE', 'ROUND', 'RESET', 'DLY_B', 'TRUE', 'MULTIPLY', 'UNSIGNED_B', 'SUBTRACT', 'ACC_FIR', 'LOAD_ACC', 'FEEDBACK', 'B', 'SHIFT_RIGHT'}
    myset2 = {'CLK', 'UNSIGNED_A', 'A', 'Z', 'SATURATE_ENABLE', 'ROUND', 'RESET', 'DLY_B', 'TRUE', 'MULTIPLY', 'UNSIGNED_B', 'SUBTRACT', 'ACC_FIR', 'LOAD_ACC', 'FEEDBACK', 'B', 'SHIFT_RIGHT'}


    # Compare ports and parameters
    ports_match = ports_module_a == ports_module_b
    params_match = params_module_a == params_module_b
    set_match = myset2 == myset1

    print("ports_match ", ports_match)

    print("params_match ", params_match)

    # Print the comparison results
    if ports_match:
        print("Ports match between the two modules.")
    else:
        print("Ports do not match between the two modules.")

    if params_match:
        print("Parameters match between the two modules.")
    else:
        print("Parameters do not match between the two modules.")

    return ports_match, params_match 



def extract_module_code(file_path):
    with open(file_path, 'r') as verilog_file:
        content = verilog_file.read()
    return content

def extract_module_ports(code):

    port_pattern = r'\b(input|output|inout|)\b\s+(?!wire|reg)\s*(\[.*?\])?\s*(\w+)\s*(,|\);)'
    ports_module = re.findall(port_pattern, code)

#    print("\nExtracted Port Lists Module ")
    port_list = []
    for port_direction, port_range, port_name, _ in ports_module:
        port_list.append(port_name)
    return port_list

def extract_module_params(code):

    parameter_pattern = r'parameter\s+(?:(?:\[\d+:\d+\])?\s+)?(\w+)\s*=\s*(.*?)(?:,|\s*;|$)'
    # Extract parameters and their values
    params_module_a = re.findall(parameter_pattern, code)
    
    lines = code.split('\n')
    parameter_list = []
    parameters = []

    for line in lines:
        match = re.search(parameter_pattern, line)
        if match:
            parameters.append((match.group(1), match.group(2)))
            parameter_list.append(match.group(1))
    
    # Print extracted parameters and ports
    print("Extracted Parameters:")
    print(parameter_list)
    return parameter_list


def check_simulation_success(filename):
    success_strings = ["Test Passed", "Simulation Passed"]
    print("file_path", filename)
    success = False
    with open(filename, 'r') as file:
        for line in file:
            if not any(success_string in line for success_string in success_strings):
                print("Simulation Successful")
                return True
            else :
                print("Simulation Failure")
                return False
    print("Simulation not successful")




#important function


#src path = Release primitve RTL path
#Destinatin path = RS FPGA PRIMTIVES REPO


def collect_old_primitives(dest_path):

    folder = dest_path
    sub_folders = [name for name in os.listdir(folder) if os.path.isdir(os.path.join(folder, name))]
    sub_folders.remove('.github')
    sub_folders.remove('.git')
    sub_folders.remove('TECHMAP')
    sub_folders.remove('sim')
    sub_folders.remove('compile_dir')
    sub_folders.remove('sim_results')
    print("----------------------------look_here++++++++++++++++++++++++++++++++",sub_folders)
    return sub_folders


def is_directory_empty(directory):
    result = not any(os.scandir(directory))
    return not any(os.scandir(directory))

def run_simulation_makefile(dest_path, design_name, tb_directory):
 #   tb_directory = f"{dest_path}" + "/" + f"{design_name}/tb"
    if not is_directory_empty(tb_directory):
        try:
            print("tb directory found", design_name, dest_path)
#            make_command = ["make", f"DESIGN_NAME={design_name}"]
            make_command = f"make  SRC_DIR={dest_path} DESIGN_NAME={design_name} TB_DIR={tb_directory}" 
            print("make command here ", make_command)
            result = subprocess.check_output(make_command, stderr=subprocess.STDOUT, text=True, shell=True)
            return True
        except subprocess.CalledProcessError as e:
            error_message = f"Command failed with error:\n{e.output}"
            print(error_message)
            return False
        

def copy_files(source_dir, destination_dir):
    try:
        # Check if the destination directory exists; if not, create it
        if not os.path.exists(destination_dir):
            os.makedirs(destination_dir)

        # Copy files from the source to the destination
        for filename in os.listdir(source_dir):
            source_file = os.path.join(source_dir, filename)
            destination_file = os.path.join(destination_dir, filename)
            if os.path.isfile(source_file):
                shutil.copy2(source_file, destination_file)

        print("Files copied successfully.")
    except Exception as e:
        print(f"Error copying files: {e}")
 

def diff_copy_parse(src_path, dest_path):

#    subdirectory =  src_path + "/sim_models_internal/"
    subdirectory =  src_path 
    #get primtives file paths and name lists
    new_primitives_paths = extract_file_paths(src_path)
    old_primitives_paths = extract_file_paths(dest_path)
    new_prim_name_list = extract_names(new_primitives_paths)   
    old_prim_name_list = extract_names(old_primitives_paths)   
    print("old_primitves\n\n\n", old_prim_name_list)
    print("new_prim_name_list \n\n\n\n", new_prim_name_list)

    new_name_list = different_primitves(dest_path , new_prim_name_list)
    print("new_name_list\n\n\n", new_name_list)

    print(type(new_primitives_paths))

    print("Files extracted successfully")


    parse_list_fail = []
    sim_fail_list = []
    sim_pass_list = []
    old_list = []

#    old_prim_set = set(collect_old_primitives(dest_path))
    new_prim_set = set(new_prim_name_list)
    old_prim_set = set(old_prim_name_list)
    new_prim_list = list(new_prim_set - old_prim_set)

    prefix_string = dest_path
    postfix_string = ".v"

    # Use a list comprehension to modify each element
    new_prim_found = [prefix_string + item + postfix_string for item in new_prim_list]
#    print("Here are three New primitves @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@", new_prim_found, new_prim_set, old_prim_set)

    for prim_name in old_list:
        old_path1 = os.path.join(dest_path, f"{prim_name}.v")
        #filepath2 = Filepath from module/verilog/
        old_path2 = os.path.join(subdirectory , f"{prim_name}.v")
        if os.path.exists(old_path2):
            ports, params = parse_primitves(old_path1,old_path2)


    for module_name in new_prim_name_list:
        tb_directory = f"{dest_path}" + "/" + f"{module_name}/tb"
        print(module_name)
        #filepath1 = File path of each module in Repo
        file_path1 = os.path.join(dest_path, f"{module_name}.v")
        #filepath2 = Filepath from module/verilog/
        file_path2 = os.path.join(subdirectory , f"{module_name}.v")
        print("file_path1=",file_path1, "file_path2=", file_path2)

        tb_directory = f"{dest_path}/../../tb/{module_name}"

#        print("comparison here", ports , params)

        copy_module_files(subdirectory, dest_path, module_name)
        print("File copied")
        diff , diff_result = check_git_diff(file_path1, module_name)
        print("---------------Diff-----------------------------", diff)
#        parse ports and parameters
        if diff:
            ports, params = parse_primitves(file_path1,file_path2)
            print("comparison here", ports , params)
            if ((ports == False) or (params == False)):
                parse_list_fail.append(dest_path + module_name + ".v")
                print("mismatch found for=", module_name)
#            print("------------------parse_list_fail---------------------------", parse_list_fail)

#            copy_module_files(subdirectory, dest_path, module_name)

            sim_out_file = dest_path + "../../" + "sim_results" +  "/" + module_name  + "_sim_out.log"
            if not is_directory_empty(tb_directory):
                result = run_simulation_makefile(dest_path, module_name,tb_directory)
                print("sim_out_file",sim_out_file)
                if result:
                    print("Simulation ran")
                    sim_status = check_simulation_success(sim_out_file)

                    if sim_status:
                        sim_pass_list.append(dest_path + module_name + ".v")
                        print("-------------------------------success----------------------------------", sim_fail_list)
                    else:
                        sim_fail_list.append(dest_path + module_name + ".v")
                        print("-------------------------------Failure----------------------------------", sim_fail_list)
        src = src_path + "../../blackbox_models"
        dest = dest_path + "../../blackbox_models"
        copy_files(src,dest)
        diff_bb = "  "
        diff_bb , diff_result = check_git_diff(dest, "cell_sim_blackbox.v")
        print("---------------Diff of blackbox----------------------", diff)
        src = src_path + "../../specs_internal"
        dest = dest_path + "../../specs_internal"
        copy_files(src,dest)        

    
        if "sim_models_internal" in src_path:
            src = src_path + "tb"
            dest = dest_path + "tb"
            copy_files(src,dest)        

        if "sim_models_internal" in src_path:
            src = src_path + "inc"
            dest = dest_path + "inc"
            copy_files(src,dest)        

    
#    print("sim_list", len(sim_fail_list), "parse_list", len(parse_list_fail))

    return sim_fail_list,sim_pass_list, parse_list_fail, new_prim_found, diff_bb, diff_result

def email_dump(sim_fail_list,parse_list_fail,  sim_pass_list,new_prim_found,release,diff_bb, diff_result,release_path):

    release_num = release
    fail_list = sim_fail_list
    parse_fail = parse_list_fail
    print("Float email")
    
    subject_content = """RS_FPGA_PRIMITIVES: Ports different than the existing primitives !!!"""

    email_content = f"""Hi owner,
    Find below the summary of the release {release_num}:
    """

    email_content_1 = f"""

    Some primitives from release: {release_num} have different ports from the exisiting primitives.

    Following New primitive have the new/modified ports.

    New Ports/Params in Primitive:

    Primitive name :
    {parse_fail}

    Examine the primitive and take appropriate action.

    """

    email_content_2 = f"""

    Some primitives from release: {release_num} does not exist in previous primitives.

    New Primitives list:
    {new_prim_found}

    Examine the primitives and take appropriate action.

    """

    email_content_3 = f"""

    Some primitives from release: {release_num} failed with the existing testbench. Kindly debug the failure and update accordingly.

    Primitive name :
    {fail_list}
    
    Examine the primitive and take appropriate action.
    """

    email_content_4 = f"""
    Kindly review the following PR for the primitives that have been updated and are passing with the existing testbench.

    Passing Primitives:
    {sim_pass_list}
    """
#        email_template = email_content.replace("<sim_fail_list>", "\n".join(sim_fail_list))

    # Define your conditions and corresponding email content
    conditions_content_pairs = [
        (len(sim_pass_list) > 0, email_content_4),
        (len(parse_list_fail) > 0, email_content_1),
        (len(new_prim_found) > 0, email_content_2),
        (len(parse_list_fail) > 0, email_content_3)
    ]
    email_template = email_content
    # Use list comprehension to conditionally select content and join it
    email_template += ''.join(content for condition, content in conditions_content_pairs if condition)

    if diff_bb is True :
        email_template += "Blackbox file cell_sims_blackbox.v has new changes, kidnly review. "
        with open("blaclbox_diff.txt", "w") as file:
                file.write(diff_result)

    if release_path is False:
        email_template += "The release does not have the required directory structure to proceed further. "


    email_template += "Auto generated email by RS FPGA Primitives CI."
    print(email_template)


    if (len(parse_list_fail) >= 0  or len(sim_fail_list) >= 0 ):
        # Write the email content to email.txt
        with open("email.txt", "w") as email_file:
            email_file.write(email_template)
        with open("subject.txt", "w") as subject_file:
            subject_file.write(subject_content)

    print("Email content generated and written to email.txt")


    # Specify the file path where you want to save the list

    # Open the file in write mode and write the list of strings
    if len(parse_fail) > 0:
        with open("Port_mismatch.txt", "w") as file:
            for string in parse_fail:
                file.write(string + "\n")
    if len(new_prim_found) > 0:
        with open("new_prim.txt", "w") as file:
            for string in new_prim_found:
                file.write(string + "\n")
    if len(fail_list) > 0:
        with open("Fail_prim.txt", "w") as file:
            for string in fail_list:
                file.write(string + "\n")
    if len(sim_pass_list) > 0:
        with open("Pass_prim.txt", "w") as file:
            for string in sim_pass_list:
                file.write(string + " ")





def main():

    #Command line arguments 
    parser = argparse.ArgumentParser(description="Process two files.")
    parser.add_argument("--release",    default="0.0.0.0", help="Path to the release file")
    parser.add_argument("--primitive",  default="default_primitive_file.txt", help="Path to the primitive file")
    parser.add_argument("--src",        default="default_source_file.txt", help="Path to the source file")
    parser.add_argument("--dest",       default="default_destination_file.txt", help="Path to the destination file")
    parser.add_argument("--sim_log",    default="default_simulation.log", help="Path to the simulation log file")
    args = parser.parse_args()

    if (check_release(args.src)):
        print("Release exist")
        sim_list, sim_pass_list, parse_list ,new_prim_found , diff_bb , diff_result = diff_copy_parse(args.src, args.dest)
        sim_pass_list
        print("sim_list", len(sim_list), "sim_pass_list", sim_pass_list,"parse_list", len(parse_list))
        email_dump(sim_list,parse_list, sim_pass_list,new_prim_found,args.release, diff_bb, diff_result, True)
    else:
        print("Release do not exist")
        email_dump([],[],[],[],args.release, "No diff found in blackbox", False, False)


main()
