//============================================================================
// Name        : optimize.cpp
// Author      : 
// Version     :
// Copyright   : Your copyright notice
// Description : Hello World in C++, Ansi-style
//============================================================================

#include <iostream>
#include <sstream>
#include <string>
#include <fstream>
#include <vector>
#include <algorithm>
#include <stdio.h>
#include <math.h>
#include <string.h>
#include <cstdlib>

using namespace std;

vector<string> pg_names;
vector<float> pg_scores;
vector<float> pg_variances;
vector<float> pg_salaries;
vector<string> sg_names;
vector<float> sg_scores;
vector<float> sg_variances;
vector<float> sg_salaries;
vector<string> sf_names;
vector<float> sf_scores;
vector<float> sf_variances;
vector<float> sf_salaries;
vector<string> pf_names;
vector<float> pf_scores;
vector<float> pf_variances;
vector<float> pf_salaries;
vector<string> c_names;
vector<float> c_scores;
vector<float> c_variances;
vector<float> c_salaries;
// aggregate lists for dk
vector<string> g_names;
vector<float> g_scores;
vector<float> g_variances;
vector<float> g_salaries;
vector<string> f_names;
vector<float> f_scores;
vector<float> f_variances;
vector<float> f_salaries;
vector<string> u_names;
vector<float> u_scores;
vector<float> u_variances;
vector<float> u_salaries;

string site;


int getPlayers(string &file, vector<string> &names, vector<float> &scores, vector<float> &variances, vector<float> &salaries) {
	ifstream infile(file);
	string line;
	int n = 0;
	while (getline(infile, line)) {
		string name;
		string score, variance, salary;
		stringstream lineStream(line);
		getline(lineStream, name, ',');
		getline(lineStream, score, ',');
		getline(lineStream, variance, ',');
		getline(lineStream, salary, ',');
		names.push_back(name);
		scores.push_back(stod(score));
		variances.push_back(stod(variance));
		salaries.push_back(stod(salary));
		n++;
	}
	return n;
}

float totalSalary(vector<int> &players) {
	if (site.compare("fd") == 0) {
		return pg_salaries[players[0]] + pg_salaries[players[1]] + sg_salaries[players[2]] + sg_salaries[players[3]] + sf_salaries[players[4]] + sf_salaries[players[5]] + pf_salaries[players[6]] + pf_salaries[players[7]] + c_salaries[players[8]];
	} else {
		return pg_salaries[players[0]] + sg_salaries[players[1]] + sf_salaries[players[2]] + pf_salaries[players[3]] + c_salaries[players[4]] + g_salaries[players[5]] + f_salaries[players[6]] + u_salaries[players[7]];
	}
}

float totalScore(vector<int> &players) {
	if (site.compare("fd") == 0) {
		return pg_scores[players[0]] + pg_scores[players[1]] + sg_scores[players[2]] + sg_scores[players[3]] + sf_scores[players[4]] + sf_scores[players[5]] + pf_scores[players[6]] + pf_scores[players[7]] + c_scores[players[8]];
	} else {
		return pg_scores[players[0]] + sg_scores[players[1]] + sf_scores[players[2]] + pf_scores[players[3]] + c_scores[players[4]] + g_scores[players[5]] + f_scores[players[6]] + u_scores[players[7]];
	}
}

float totalVariance(vector<int> &players) {
	if (site.compare("fd") == 0) {
		return sqrt(pg_variances[players[0]] + pg_variances[players[1]] + sg_variances[players[2]] + sg_variances[players[3]] + sf_variances[players[4]] + sf_variances[players[5]] + pf_variances[players[6]] + pf_variances[players[7]] + c_variances[players[8]]);
	} else {
		return sqrt(pg_variances[players[0]] + sg_variances[players[1]] + sf_variances[players[2]] + pf_variances[players[3]] + c_variances[players[4]] + g_variances[players[5]] + f_variances[players[6]] + u_variances[players[7]]);
	}
}

bool compareOptions(vector<int> option1, vector<int> option2) {
	return ((totalScore(option1) - totalVariance(option1)) > (totalScore(option2) - totalVariance(option2)));
}

bool compareTournOptions(vector<int> option1, vector<int> option2) {
	return ((totalScore(option1) + totalVariance(option1)) > (totalScore(option2) + totalVariance(option2)));
}

vector< vector<int> > getOptions(int pg_n, int sg_n, int sf_n, int pf_n, int c_n) {
	vector< vector<int> > options;
	if (site.compare("fd") == 0) {
		for (int i = 0; i < pg_n; i++) {
			for (int j = 1; j < pg_n; j++) {
				if (j <= i) { continue; }
				for (int k = 0; k < sg_n; k++) {
					for (int l = 1; l < sg_n; l++) {
						if (l <= k) { continue; }
						for (int m = 0; m < sf_n; m++) {
							for (int n = 1; n < sf_n; n++) {
								if (n <= m) { continue; }
								for (int o = 0; o < pf_n; o++) {
									for (int p = 1; p < pf_n; p++) {
										if (p <= o) { continue; }
										for (int q = 0; q < c_n; q++) {
											vector<int> option = {i, j, k, l, m, n, o, p, q};
											float cost = totalSalary(option);
											float budget = 60.0;
											float min_usage = 59.0;
											if (cost <= budget && cost >= min_usage) {
												options.push_back(option);
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	} else if (site.compare("dk") == 0){
		int g_n = pg_n + sg_n;
		int f_n = sf_n + pf_n;
		int u_n = g_n + f_n + c_n;
		for (int i = 0; i < pg_n; i++) {
			for (int j = 0; j < sg_n; j++) {
				for (int k = 0; k < sf_n; k++) {
					for (int l = 0; l < pf_n; l++) {
						for (int m = 0; m < c_n; m++) {
							// pick another guard
							for (int n = 0; n < g_n; n++) {
								if ( (n <= i) || ((n >= pg_n) && (n - pg_n) <= j) ) { continue; }
									// pick another forward
									for (int o = 0; o < f_n; o++) {
										if ( (o <= k) || ((o >= sf_n) && (o - sf_n) <= l) ) { continue; }
											// pick a utility
											for (int p = 0; p < u_n; p++) {
												if ((p <= i) || // not pg repeat
													((p >= pg_n) && (p - pg_n) <= j) || // sg repeat
													((p >= g_n) && (p - pg_n) <= k) || // sf repeat
													((p >= (g_n + sf_n)) && (p - g_n - sf_n) <= l) || // pf repeat
													(p <= n) || // not guard repeat
													((p >= g_n) && (p - g_n) <= o) || // not forward repeat
													((p >= (g_n + f_n)) && ((p - g_n - f_n) <= m)) ) // not center repeat
												{ continue; }
												vector<int> option = {i, j, k, l, m, n, o, p};
												float cost = totalSalary(option);
												float budget = 50.0;
												float min_usage = 49.0;
												if (cost <= budget && cost >= min_usage) {
													options.push_back(option);
												}
											}
										}
									}
								}
							}
						}
					}
				}
	}
	return options;
}

void saveOptions(vector< vector<int> > options, int n, char* file) {
	FILE * outfile;
	outfile = fopen(file, "a");
	if (n > options.size()) {
		n = options.size();
	}
	if (site.compare("fd") == 0) {
		for (int i = 0; i < n; i++) {
			fprintf(outfile,
				"[ %s, %s, %s, %s, %s, %s, %s, %s, %s ]\nPredicted score: %5.5f (+/- %4.4f), Cost: $%3.3fk\n\n",
				pg_names[options[i][0]].c_str(),
				pg_names[options[i][1]].c_str(),
				sg_names[options[i][2]].c_str(),
				sg_names[options[i][3]].c_str(),
				sf_names[options[i][4]].c_str(),
				sf_names[options[i][5]].c_str(),
				pf_names[options[i][6]].c_str(),
				pf_names[options[i][7]].c_str(),
				c_names[options[i][8]].c_str(),
				totalScore(options[i]),
				totalVariance(options[i]),
				totalSalary(options[i])
			);
		}
	} else {
		for (int i = 0; i < n; i++) {
			fprintf(outfile,
				"[ %s, %s, %s, %s, %s, %s, %s, %s ]\nPredicted score: %5.5f (+/- %4.4f), Cost: $%3.3fk\n\n",
				pg_names[options[i][0]].c_str(),
				sg_names[options[i][1]].c_str(),
				sf_names[options[i][2]].c_str(),
				pf_names[options[i][3]].c_str(),
				c_names[options[i][4]].c_str(),
				g_names[options[i][5]].c_str(),
				f_names[options[i][6]].c_str(),
				u_names[options[i][7]].c_str(),
				totalScore(options[i]),
				totalVariance(options[i]),
				totalSalary(options[i])
			);
		}
	}
}

int main(int argc, char* argv[]) {
	if (strcmp(argv[4], "fd") == 0) {
		site = "fd";
	} else {
		site = "dk";
	}
	string pg_file = "positions/" + site + "_pgs.csv";
	int pg_n = getPlayers(pg_file, pg_names, pg_scores, pg_variances, pg_salaries);
	string sg_file = "positions/" + site + "_sgs.csv";
	int sg_n = getPlayers(sg_file, sg_names, sg_scores, sg_variances, sg_salaries);
	string sf_file = "positions/" + site + "_sfs.csv";
	int sf_n = getPlayers(sf_file, sf_names, sf_scores, sf_variances, sf_salaries);
	string pf_file = "positions/" + site + "_pfs.csv";
	int pf_n = getPlayers(pf_file, pf_names, pf_scores, pf_variances, pf_salaries);
	string c_file = "positions/" + site + "_cs.csv";
	int c_n = getPlayers(c_file, c_names, c_scores, c_variances, c_salaries);
	// Extra lists for DK
	// scores
	g_scores = pg_scores;
	g_scores.insert(g_scores.end(), sg_scores.begin(), sg_scores.end());
	f_scores = sf_scores;
	f_scores.insert(f_scores.end(), pf_scores.begin(), pf_scores.end());
	u_scores = pg_scores;
	u_scores.insert(u_scores.end(), sg_scores.begin(), sg_scores.end());
	u_scores.insert(u_scores.end(), sf_scores.begin(), sf_scores.end());
	u_scores.insert(u_scores.end(), pf_scores.begin(), pf_scores.end());
	u_scores.insert(u_scores.end(), c_scores.begin(), c_scores.end());
	// names
	g_names = pg_names;
	g_names.insert(g_names.end(), sg_names.begin(), sg_names.end());
	f_names = sf_names;
	f_names.insert(f_names.end(), pf_names.begin(), pf_names.end());
	u_names = pg_names;
	u_names.insert(u_names.end(), sg_names.begin(), sg_names.end());
	u_names.insert(u_names.end(), sf_names.begin(), sf_names.end());
	u_names.insert(u_names.end(), pf_names.begin(), pf_names.end());
	u_names.insert(u_names.end(), c_names.begin(), c_names.end());
	// salaries
	g_salaries = pg_salaries;
	g_salaries.insert(g_salaries.end(), sg_salaries.begin(), sg_salaries.end());
	f_salaries = sf_salaries;
	f_salaries.insert(f_salaries.end(), pf_salaries.begin(), pf_salaries.end());
	u_salaries = pg_salaries;
	u_salaries.insert(u_salaries.end(), sg_salaries.begin(), sg_salaries.end());
	u_salaries.insert(u_salaries.end(), sf_salaries.begin(), sf_salaries.end());
	u_salaries.insert(u_salaries.end(), pf_salaries.begin(), pf_salaries.end());
	u_salaries.insert(u_salaries.end(), c_salaries.begin(), c_salaries.end());
	// variances
	g_variances = pg_variances;
	g_variances.insert(g_variances.end(), sg_variances.begin(), sg_variances.end());
	f_variances = sf_variances;
	f_variances.insert(f_variances.end(), pf_variances.begin(), pf_variances.end());
	u_variances = pg_variances;
	u_variances.insert(u_variances.end(), sg_variances.begin(), sg_variances.end());
	u_variances.insert(u_variances.end(), sf_variances.begin(), sf_variances.end());
	u_variances.insert(u_variances.end(), pf_variances.begin(), pf_variances.end());
	u_variances.insert(u_variances.end(), c_variances.begin(), c_variances.end());


	cout << "Generating options" << endl;
	vector< vector<int> > options = getOptions(pg_n, sg_n, sf_n, pf_n, c_n);

	if (options.size() > 0) {
		if (strcmp(argv[3], "double") == 0) {
			cout << "Sorting for doubles" << endl;
			sort(options.begin(), options.end(), compareOptions);
		} else {
			cout << "Sorting for tournaments" << endl;
			sort(options.begin(), options.end(), compareTournOptions);
		}
		cout << "Saving options to " << argv[2] << endl;
		saveOptions(options, atoi(argv[1]), argv[2]);
	} else {
		cout << "No valid options available\n";
	}

	return 0;
}
