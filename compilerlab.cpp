#include <iostream>
#include <fstream>
#include <sstream>
#include <list>
#include <string>
#include <set>
#include <stack>  
#include <map>
#include <regex>
#include <cmath>
using namespace std;
struct word {
	std::string type; //识别这个词属于哪种类型
	std::string content; //这个词具体是什么符号
	int address = -1; //当这个标识符是变量的时候，用来记录这个变量的地址信息
};

// 调用flex
extern FILE *yyin, *yyout;
extern int yylex (void);
extern void OutputData(const char *pFileName);

int global_address = 4;
std::map<std::string, int> Variable_Address;// 记录所有的变量名，以及其对应的地址
std::list<word> splited_src; // 存储着所有被分割的词
set<string> KEYWORDS = {"int", "return", "main"};
set<string> OPERATORS = {"+", "-", "*", "=", "/", "(", ")", "%", "<", "<=", ">", ">=", "==", "!=", "&", "|", "^", "||", "&&", "!", "~"};
set<string> FUNCTION = {"println_int"};
string src_path;
string src;
list<string> compiler_src; // 汇编结果

// 这个是运算部分的代码
int transvalue(string c) {
	if (c == "(") {
		return 1;
	}
	else if (c == "||") {
		return 2;
	}
	else if (c == "&&") {
		return 3;
	}
	else if (c == "|") {
		return 4;
	}
	else if (c == "^") {
		return 5;
	}
	else if (c == "&") {
		return 6;
	}
	else if (c == "!=" || c == "==") {
		return 7;
	}
	else if (c == "<") {
		return 8;
	}
	else if (c == ">") {
		return 8;
	}
	else if (c == "<=") {
		return 8;
	}
	else if (c == ">=") {
		return 8;
	}
	else if (c == "+" || c == "-") {
		return 9;
	}
	else if (c == "*") {
		return 12;
	}
	else if (c == "%") {
		return 12;
	}
	else if (c == "/") {
		return 12;
	}
	else if (c == "!" || c == "~" || c == "@") { // 用@代替负号，如果有负号含义的就当做一个数字和后面紧跟的字符进行处理
		return 13;
	} else if (c == ")") {
		return 14;
	}
	else {
		return 0;
	}
}

bool judgeopt(string a, string b) {
	int value1 = transvalue(a);
	int value2 = transvalue(b);
	return value1 >= value2;
}

list<word> cal(list<word> str) {
	stack<word> opt, exp;
	string ch;    //用一个ch来表示str[i]  
	// 扫描输入  
	for (word w: str) {
		ch = w.content;
		//操作数直接压栈  
		if (w.type == "ID" || w.type == "INT_VALUE") {
			exp.push(w);
		}
		else {
			if (ch == "(") {//左括号直接压栈  
				opt.push(w);
			}
			else if (ch == ")")//右括号则取opt中对应的操作符存入exp中  
			{
				while (opt.top().content != "(") {
					exp.push(opt.top());
					opt.pop();
				}
				opt.pop();//舍弃栈顶的左括号  
			}
			else {//判断运算符   
				if (opt.empty() || (judgeopt(w.content, opt.top().content))) {//优先级大直接存入  
					opt.push(w);
				}
				else {  //优先级小，栈顶元素出栈  
					while (!opt.empty()) {//继续出栈  
						if (judgeopt(opt.top().content, ch)) {
							exp.push(opt.top());
							opt.pop();
						}
						else {
							break;
						}
					}
					opt.push(w);//最后ch存入opt  
				}
			}
		}
	}

	while (!opt.empty()) {
		exp.push(opt.top());
		opt.pop();
	}

	str.push_back(str.front());
	int num = 1;
	while (!exp.empty()) {
		num++;
		str.push_back(exp.top());
		exp.pop();
	}
	str.reverse();
	list<word> suffix;
	for (word w : str) {
		num--;
		if (num == 0) {
			break;
		}
		suffix.push_back(w);
	}
	return suffix;
}

string trans_push_var(word w) {
	if (w.type == "ID") {
		string assemble = "mov eax, DWORD PTR [ebp-" + to_string(Variable_Address[w.content]) + "]\n";
		assemble += "push eax";
		return assemble;
	}
	else {
		string assemble = "mov eax, " + w.content + "\n";
		assemble += "push eax";
		return assemble;
	}
}

string trans_pop_var() {
	return "pop ebx\npop eax";
}

//从文件读入到string里
string readFileIntoString(string filename)
{
	ifstream ifile(filename);
	//将文件读入到ostringstream对象buf中
	ostringstream buf;
	char ch;
	while (buf && ifile.get(ch))
		buf.put(ch);
	//返回与流对象buf关联的字符串
	return buf.str();
}

string structure_of_sentence(list<word> s) {
	/* 存储了所有编译器能接受的句法结构，使用op / kw / var_name / var_val / ;
	   这5种类型名称来表示,其中一些是集合一些是单个符号,
	   键表示这种正则式，
	   我们输入某个正则式检测是否是这个正则式，如果是的话就可以映射为对应的名称
	*/
	/*
	* 0. ;这个符号被我们直接截取了，不用做解析了
	* 1. 初始化结构 int a  -> kwvar_name
	* 2. 赋值语句结构 a = 1 -> var_name=var_val
	* 3. 运算语句 d = a + b -> var_name=op^*(var_val|var_name)(op^*)(op(var_val|var_name))^*(var_val|var_name)
	* 4. return 语句 return d -> kwvar_name //和1无法区分
	*/
	string type_sequence;
	for (word w : s) {
		type_sequence += w.type;
	}
	regex int_main("TYPEreservewordLP.*RPLC.*"); //识别int main(.){.模式
	regex end("RC"); //识别int main(.){.模式
	regex init("TYPEID");
	regex r_return("RETURN(ID|INT_VALUE)");
	regex give("IDASSIGNOPINT_VALUE"); // 这个是变量值赋给变量名，不包含变量给变量复制，如果有变量在等号右侧，则归为op
	regex op("IDASSIGNOP(.)*");
	regex func("IDLP.*RP");
	if (regex_match(type_sequence, int_main)){
		return "int_main";
	}
	else if (regex_match(type_sequence, init)){
		return "init";
	}
	else if (regex_match(type_sequence, give)) {
		return "give";
	}
	else if (regex_match(type_sequence, func)) {
		return "func";
	}
	else if (regex_match(type_sequence, op)) {
		return "cal";
	}
	else if (regex_match(type_sequence, r_return)){
		return "return";
	}
	else if (regex_match(type_sequence, end)) {
		return "end";
	}
	// debug，当有未定义的语法形式出现的时候会报这个错
	// cout << endl;
	// cout << type_sequence;
	// cout << endl;
	return "unknown";
}

int add_address(string type) {
	if (type == "int") {
		return 4;
	}
	else {
		return 0;
	}
	// 可以继续添加不同变量对应的地址增加方式
}

void split_src() {
	stringstream ss(src);
	string w, t;
	while (ss >> w >> t) { // Extract word from the stream.
		splited_src.push_back(word{t, w, -1});
	}
}

void translate_sentence(string st, list<word> s) {
	if (st == "init" || st == "return") {
		string keyword = s.front().content;
		if (keyword == "int") {
			s.pop_front();
			if (Variable_Address.find(s.front().content) == Variable_Address.end()) { // 检测这个变量是否出现过，如果出现过，那么地址就不需要变，而是取之前这个同名变量的地址赋予即可
				Variable_Address[s.front().content] = global_address;
				s.front().address = global_address;
				global_address += add_address("int");
			}
			else {// 当能找到时说明这个变量已经出现过了，不需要增加变量地址，直接赋给即可
				s.front().address = Variable_Address[s.front().content];
			}
			int address = s.front().address;
			string assemble = "mov DWORD PTR [ebp-" + to_string(address) + "], 0";
			compiler_src.push_back(assemble);
		}
		else if (keyword == "return") {
			s.pop_front();
            if (s.front().type == "ID") {
                if (Variable_Address.find(s.front().content) == Variable_Address.end()) { // 检测这个变量是否出现过，如果出现过，那么地址就不需要变，而是取之前这个同名变量的地址赋予即可
                    cout << "variable you want to return is undefined." << endl;
                }
                else {// 当能找到时说明这个变量已经出现过了，不需要增加变量地址，直接赋给即可
                    s.front().address = Variable_Address[s.front().content];
                }
            }
			int address = s.front().address;
			if (address == -1) {// 直接就是变量
				string assemble = "mov eax, " + s.front().content;
				compiler_src.push_back(assemble);
			}
			else {
				string assemble = "mov eax, DWORD PTR [ebp-" + to_string(address) + "]";
				compiler_src.push_back(assemble);
			}
		}
	}
	else if (st == "give") {
		int address = Variable_Address[s.front().content];
		s.pop_front(); // 将变量名删掉
		s.pop_front(); // 将等于号删掉
		string var_val = s.front().content;
		string assemble = "mov DWORD PTR [ebp-" + to_string(address) + "], " + var_val + "\n";
		compiler_src.push_back(assemble);
	}
	else if (st == "cal") {
		s.front().address = Variable_Address[s.front().content];
		word before_equal = s.front();
		s.pop_front();
		s.pop_front();
		list<word> suffix_exp = cal(s);
		while (!suffix_exp.empty()) {
			// cout << suffix_exp.front().content << " ";
			word tmp = suffix_exp.front();
			if (tmp.content == "+") {
				compiler_src.push_back(trans_pop_var());
				compiler_src.push_back("add eax, ebx\npush eax");
			}
			else if (tmp.content == "-") {
				compiler_src.push_back(trans_pop_var());
				compiler_src.push_back("sub eax, ebx\npush eax");
			}
			else if (tmp.content == "*") {
				compiler_src.push_back(trans_pop_var());
				compiler_src.push_back("imul eax, ebx\npush eax");
			}
			else if (tmp.content == "/") {
				compiler_src.push_back(trans_pop_var());
				compiler_src.push_back("cdq\nidiv ebx\npush eax");
			}
			else if (tmp.content == "%") {
				compiler_src.push_back(trans_pop_var());
				compiler_src.push_back("cdq\nidiv ebx\npush edx");
			}
			else if (tmp.content == "<") {
				compiler_src.push_back(trans_pop_var()); // 取出两个数，在汇编上
				compiler_src.push_back("cmp eax, ebx\nsetl al\nmovzx eax, al\npush eax");
			}
			else if (tmp.content == ">") {
				compiler_src.push_back(trans_pop_var());
				compiler_src.push_back("cmp eax, ebx\nsetg al\nmovzx eax, al\npush eax");
			}
			else if (tmp.content == "<=") {
				compiler_src.push_back(trans_pop_var());
				compiler_src.push_back("cmp eax, ebx\nsetle al\nmovzx eax, al\npush eax");
			}
			else if (tmp.content == ">=") {
				compiler_src.push_back(trans_pop_var());
				compiler_src.push_back("cmp eax, ebx\nsetge al\nmovzx eax, al\npush eax");
			}
			else if (tmp.content == "==") {
				compiler_src.push_back(trans_pop_var());
				compiler_src.push_back("cmp eax, ebx\nsete al\nmovzx eax, al\npush eax");
			}
			else if (tmp.content == "!=") {
				compiler_src.push_back(trans_pop_var());
				compiler_src.push_back("cmp eax, ebx\nsetne al\nmovzx eax, al\npush eax");
			}
			else if (tmp.content == "&") {
				compiler_src.push_back(trans_pop_var());
				compiler_src.push_back("and eax, ebx\npush eax");
			}
			else if (tmp.content == "|") {
				compiler_src.push_back(trans_pop_var());
				compiler_src.push_back("or eax, ebx\npush eax");
			}
			else if (tmp.content == "^") {
				compiler_src.push_back(trans_pop_var());
				compiler_src.push_back("xor eax, ebx\npush eax");
			}
			else {
				compiler_src.push_back(trans_push_var(tmp));
			}
			suffix_exp.pop_front();
		}
		compiler_src.push_back("pop eax\nmov DWORD PTR [ebp-" + to_string(before_equal.address) + "], eax");
	}
	else if (st == "func") {
		s.pop_front();
		s.pop_front();
		s.front().address = Variable_Address[s.front().content];
		string assemble = "";
		if (s.front().type == "ID") {
			assemble += "push DWORD PTR [ebp-" + to_string(s.front().address) + "]\n";
		}
		else {
			assemble += "push " + s.front().content + "\n";
		}
		assemble += "push offset format_str\n";
		assemble += "call printf\n";
		assemble += "add esp, 8\n";
		compiler_src.push_back(assemble);
	}
	else if (st == "int_main") {
		while (s.front().content != "{") {
			s.pop_front();
		}
		s.pop_front();
		translate_sentence("init", s);
	}
}

void my_translate() {
	list<word> sentence;
	for (word w : splited_src) {
		if (w.content != ";") {
			sentence.push_back(w);
			// cout << w.content << ' ';
		}
		else { // 完成了一句话的读取，就直接开始解析
			string structure = structure_of_sentence(sentence);
			// cout << endl;
			// cout << structure << endl;
			translate_sentence(structure, sentence);
			sentence.clear();
		}
	}
}

void output() {
	// 输出框架
	cout << ".intel_syntax noprefix" << endl;
	cout << ".global main" << endl;
	cout << ".extern printf" << endl;
	cout << ".data" << endl;
	cout << "format_str:" << endl;
	cout << ".asciz \"%d\\n\"" << endl;
	cout << ".text" << endl;
	cout << "main:" << endl;
	cout << "push ebp" << endl;
	cout << "mov ebp, esp" << endl;
	cout << "sub esp, 0x100" << endl;
	for (string l : compiler_src) {
		cout << l << endl;
	}
	cout << "leave" << endl;
	cout << "ret" << endl;
}

void parse() {
	if (!(yyin = fopen(src_path.c_str(), "r"))) {
		cout << "parse error";
	}
	yylex();
	OutputData("splited_words.txt");
	src = readFileIntoString("splited_words.txt");
}

int main(int args, char** argv) {
	src_path = argv[1];
	// src_path = "../c.c";
	parse();
	split_src();
	my_translate();
	output();
	return 0;
}
