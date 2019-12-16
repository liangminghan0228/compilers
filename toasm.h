#include<fstream>

void write_to_asm() {
    string content = "";
    ofstream file;
    file.open("target.asm", ios::out);

    file<<"extern printf"<<endl;
    file<<"extern scanf"<<endl;
    file<<"extern exit"<<endl;

    file<<endl<<"section .data"<<endl;
    file<<"\tprint_format db \"%d\", 0ah, 0dh, 0"<<endl;
    file<<"\tscanf_format db \"%d\", 0"<<endl;

    file<<endl<<"section .bss"<<endl;
    //声明用户声明的变量
    for(int i=0; i<table_list.size(); i++) {
        file<<"\t"<<table_list[i]<<":times 4 resb 4"<<endl;
    }
    //声明临时变量
    for(int i=0; i<code_list.size(); i++) {
        if(code_list[i]->res && code_list[i]->res->istemp) {
            file<<"\t"<<code_list[i]->res->key<<":times 4 resb 4"<<endl;
        }
    }
    //代码段
    file<<endl<<"section .code"<<endl;
    file<<"\tglobal main"<<endl;
    file<<"main:"<<endl;
    for(int i=0; i<code_list.size(); i++) {
        char buffer[20];
        sprintf(buffer, "%d", i);
        string num = string(buffer);
        string label = "label" + num;
        file<<label<<":"<<endl;
        string arg1 = "", arg2 = "";
        if(code_list[i]->arg1)
        {
            arg1 = (code_list[i]->arg1->key[0]>='0' && code_list[i]->arg1->key[0]<='9')? code_list[i]->arg1->key:
            "dword [" + code_list[i]->arg1->key + "]";
        }
        if(code_list[i]->arg2)
        {
            arg2 = (code_list[i]->arg2->key[0]>='0' && code_list[i]->arg2->key[0]<='9')? code_list[i]->arg2->key:
            "dword [" + code_list[i]->arg2->key + "]";
        }
        //有操作运算的且没有跳转指令
        if(code_list[i]->op != "" && code_list[i]->goto_pos == -1) {
            if(code_list[i]->op == "+") {
                file<<"\t;加法"<<endl;
                file<<"\tmov eax, "<<arg1<<endl;
                file<<"\tadd eax, "<<arg2<<endl;
                file<<"\tmov  dword ["<<code_list[i]->res->key<<"], eax"<<endl<<endl;
            }
            else if(code_list[i]->op == "-") {
                file<<"\t;减法"<<endl;
                file<<"\tmov eax, "<<arg1<<endl;
                file<<"\tsub eax, "<<arg2<<endl;
                file<<"\tmov  dword ["<<code_list[i]->res->key<<"], eax"<<endl<<endl;
            }

            else if(code_list[i]->op == "*") {
                file<<"\t;乘法"<<endl;
                file<<"\tmov eax, "<<arg1<<endl;
                file<<"\tmov ebx, "<<arg2<<endl;
                file<<"\txor  edx,edx"<<endl;
                file<<"\timul ebx"<<endl;
                file<<"\tmov dword ["<<code_list[i]->res->key<<"], eax"<<endl<<endl;
            }

            else if(code_list[i]->op == "/") {
                file<<"\t;除法"<<endl;
                file<<"\tmov eax, "<<arg1<<endl;
                file<<"\tmov ebx, "<<arg2<<endl;
                file<<"\txor  edx,edx"<<endl;
                file<<"\tidiv ebx"<<endl;
                file<<"\tmov dword ["<<code_list[i]->res->key<<"], eax"<<endl<<endl;
            }

            else if(code_list[i]->op == "%") {
                file<<"\t;求余"<<endl;
                file<<"\tmov eax, "<<arg1<<endl;
                file<<"\tmov ebx, "<<arg2<<endl;
                file<<"\txor  edx,edx"<<endl;
                file<<"\tidiv ebx"<<endl;
                file<<"\tmov dword ["<<code_list[i]->res->key<<"], edx"<<endl<<endl;
            }

            else if(code_list[i]->op == "++") {
            
                if(code_list[i]->arg1) {//i++
                    file<<"\t;i++"<<endl;
                    file<<"\tmov eax, "<<arg1<<endl;
                    file<<"\tmov dword ["<<code_list[i]->res->key<<"], eax"<<endl;
                    file<<"\tinc eax"<<endl;
                    file<<"\tmov "<<arg1<<", eax"<<endl;
                }
                else {//++i
                    file<<"\t;++i"<<endl;
                    file<<"\tmov eax, "<<arg2<<endl;
                    file<<"\tinc eax"<<endl;
                    file<<"\tmov dword ["<<code_list[i]->res->key<<"], eax"<<endl;
                    file<<"\tmov "<<arg2<<", eax"<<endl;
                }
            }

            else if(code_list[i]->op == "--") {
                if(code_list[i]->arg1) {//i--
                    file<<"\t;i--"<<endl;
                    file<<"\tmov eax, "<<arg1<<endl;
                    file<<"\tmov dword ["<<code_list[i]->res->key<<"], eax"<<endl;
                    file<<"\tsub eax, 1"<<endl;
                    file<<"\tmov "<<arg1<<", eax"<<endl;
                }
                else {//--i
                    file<<"\t;--i"<<endl;
                    file<<"\tmov eax, "<<arg2<<endl;
                    file<<"\tsub eax, 1"<<endl;
                    file<<"\tmov dword ["<<code_list[i]->res->key<<"], eax"<<endl;
                    file<<"\tmov "<<arg2<<", eax"<<endl;
                }
            }

            else if(code_list[i]->op == "&&") {
                file<<"\t;and"<<endl;
                file<<"\tmov eax, "<<arg1<<endl;
                file<<"\tand eax, "<<arg2<<endl;
                file<<"\tmov dword ["<<code_list[i]->res->key<<"], eax"<<endl<<endl;
            }

            else if(code_list[i]->op == "||") {
                file<<"\t;or"<<endl;
                file<<"\tmov eax, "<<arg1<<endl;
                file<<"\tor eax, "<<arg2<<endl;
                file<<"\tmov dword ["<<code_list[i]->res->key<<"], eax"<<endl<<endl;
            }

            else if(code_list[i]->op == "<") {
                file<<"\t;小于"<<endl;
                string label1 = label + "_1";
                string label2 = label + "_2";
	            file<<"\tmov dword ["<<code_list[i]->res->key<<"], 0"<<endl;
	            file<<"\tmov eax, "<<arg1<<endl;
	            file<<"\tcmp eax, "<<arg2<<endl;
	            file<<"\tjl "<<label1<<endl;
                file<<"\tjmp "<<label2<<endl;
                file<<label1<<":"<<endl;
                file<<"\tmov dword ["<<code_list[i]->res->key<<"], 1"<<endl;
	            file<<label2<<":"<<endl;
            }

            else if(code_list[i]->op == ">") {
                file<<"\t;大于"<<endl;
                string label1 = label + "_1";
                string label2 = label + "_2";
	            file<<"\tmov dword ["<<code_list[i]->res->key<<"], 0"<<endl;
	            file<<"\tmov eax, "<<arg1<<endl;
	            file<<"\tcmp eax, "<<arg2<<endl;
	            file<<"\tjg "<<label1<<endl;
                file<<"\tjmp "<<label2<<endl;
                file<<label1<<":"<<endl;
                file<<"\tmov dword ["<<code_list[i]->res->key<<"], 1"<<endl;
	            file<<label2<<":"<<endl;
            }

            else if(code_list[i]->op == ">=") {
                file<<"\t;大于等于"<<endl;
                string label1 = label + "_1";
                string label2 = label + "_2";
	            file<<"\tmov dword ["<<code_list[i]->res->key<<"], 0"<<endl;
	            file<<"\tmov eax, "<<arg1<<endl;
	            file<<"\tcmp eax, "<<arg2<<endl;
	            file<<"\tjge "<<label1<<endl;
                file<<"\tjmp "<<label2<<endl;
                file<<label1<<":"<<endl;
                file<<"\tmov dword ["<<code_list[i]->res->key<<"], 1"<<endl;
	            file<<label2<<":"<<endl;
            }

            else if(code_list[i]->op == "<=") {
                file<<"\t;小于等于"<<endl;
                string label1 = label + "_1";
                string label2 = label + "_2";
	            file<<"\tmov dword ["<<code_list[i]->res->key<<"], 0"<<endl;
	            file<<"\tmov eax, "<<arg1<<endl;
	            file<<"\tcmp eax, "<<arg2<<endl;
	            file<<"\tjle "<<label1<<endl;
                file<<"\tjmp "<<label2<<endl;
                file<<label1<<":"<<endl;
                file<<"\tmov dword ["<<code_list[i]->res->key<<"], 1"<<endl;
	            file<<label2<<":"<<endl;
            }

            else if(code_list[i]->op == "==") {
                file<<"\t;等于"<<endl;
                string label1 = label + "_1";
                string label2 = label + "_2";
	            file<<"\tmov dword ["<<code_list[i]->res->key<<"], 0"<<endl;
	            file<<"\tmov eax, "<<arg1<<endl;
	            file<<"\tcmp eax, "<<arg2<<endl;
	            file<<"\tje "<<label1<<endl;
                file<<"\tjmp "<<label2<<endl;
                file<<label1<<":"<<endl;
                file<<"\tmov dword ["<<code_list[i]->res->key<<"], 1"<<endl;
	            file<<label2<<":"<<endl;
            }

            else if(code_list[i]->op == "!=") {
                file<<"\t;不等于"<<endl;
                string label1 = label + "_1";
                string label2 = label + "_2";
	            file<<"\tmov dword ["<<code_list[i]->res->key<<"], 0"<<endl;
	            file<<"\tmov eax, "<<arg1<<endl;
	            file<<"\tcmp eax, "<<arg2<<endl;
	            file<<"\tjne "<<label1<<endl;
                file<<"\tjmp "<<label2<<endl;
                file<<label1<<":"<<endl;
                file<<"\tmov dword ["<<code_list[i]->res->key<<"], 1"<<endl;
	            file<<label2<<":"<<endl;
            }

            else if(code_list[i]->op == "!") {
                file<<"\t;非"<<endl;
                string label1 = label + "_1";
                string label2 = label + "_2";
	            file<<"\tmov eax, "<<arg1<<endl;
	            file<<"\tcmp eax, 0"<<endl;
	            file<<"\tje "<<label1<<endl;
	            file<<"\tmov dword ["<<code_list[i]->res->key<<"], 0"<<endl;
	            file<<"\tjmp "<<label2<<endl;
                file<<label1<<":"<<endl;
	            file<<"mov dword ["<<code_list[i]->res->key<<"], 1"<<endl;
                file<<label2<<":"<<endl;
            }

            else if(code_list[i]->op == "&") {
                file<<"\t;取某个变量的地址"<<endl;
                file<<"\tmov eax, "<<code_list[i]->arg1->key<<endl;
                file<<"\tmov dword ["<<code_list[i]->res->key<<"], eax"<<endl;
            }

            else if(code_list[i]->op == "~") {
                file<<"\t;取某个地址的变量"<<endl;
                file<<"\tmov eax, "<<arg1<<endl;
                file<<"\tmov ebx, [eax]"<<endl;
                file<<"\tmov dword ["<<code_list[i]->res->key<<"], ebx"<<endl;
            }

            else if(code_list[i]->op == "=") {
                file<<"\t;赋值"<<endl;
                file<<"\tmov eax, "<<arg1<<endl;
                file<<"\tmov dword ["<<code_list[i]->res->key<<"], eax"<<endl<<endl;
            }

            else if(code_list[i]->op == "print") {
                file<<"\t;输出"<<endl;
                file<<"\tpush "<<arg1<<endl;
                file<<"\tpush print_format"<<endl;
                file<<"\tcall printf"<<endl;
            }
            else if(code_list[i]->op == "scanf") {
                file<<"\t;输入"<<endl;
                file<<"\tpush "<<code_list[i]->arg1->key<<endl;
                file<<"\tpush scanf_format"<<endl;
                file<<"\tcall scanf"<<endl;
            }
        }
        //跳转语句
        else if(code_list[i]->goto_pos != -1)  {
            //条件跳转
            if(code_list[i]->op == "!=")
            {
                char buffer[20];
                sprintf(buffer, "%d", code_list[i]->goto_pos);
                string label1 = "label" + string(buffer);
                file<<"\t;条件跳转"<<endl;
                file<<"\tmov eax, "<<arg1<<endl;
                file<<"\tcmp eax, "<<arg2<<endl;
                file<<"\tjne "<<label1<<endl;
            }
            //无条件跳转
            else if(code_list[i]->op == "") {
                char buffer[20];
                sprintf(buffer, "%d", code_list[i]->goto_pos);
                string label1 = "label" + string(buffer);
                file<<"\t;无条件跳转"<<endl;
                file<<"\tjmp "<<label1<<endl;
            }
        }
    }

    //退出
    char buffer[20];
    int size = code_list.size();
    sprintf(buffer, "%d", size);
    string num = string(buffer);
    file<<"label"<<num<<":"<<endl;
    file<<endl<<"\tpush 0"<<endl;
    file<<"\tcall exit"<<endl;
}

