# 1. Introduction
The CAST Quality Model provides thousands of Quality Rules for dozens of different programming languages and architectural best-practices. The results of a normal assessment with CAST AIP for a medium-sized application typically contain tens of thousands of violations. The violations lead to the calculation of the values for each quality rule, and then to the value of aggregated KPIs.

_The cost or the effort of removing all defects for an application is almost always too high_. It happens especially in Agile ALM and in DevOps context, when it is needed provide enhancements and structural improvements to the users in a very short time. 

Therefore, AIP provides the feature of selecting specific violations and grouping them in Action Plans. An Action plan is a subset of violations selected to be removed from the application, typically in the next development cycle.

_Which are the violations that should be selected?_ It depends on the user's target. The user might choose to target as much as possible one or more business factor (Security, Robustness, Efficiency, Changeability, Transferability, … or all of them: the whole Total Quality Index), under the constraint of limited resources.

_Which are the violations that give the maximum advantage to reaching the target?_ It depends on many factors:
* There are rules with different weights (In effect in the CAST Quality model there are two levels of aggregation, so you must consider the weight of the rule for calculating the Technical Criteria to which it contributes, and then the weight of the TC for the calculation of the Business Factor)
* Rules have different normalization thresholds (the percentage of violations for each rule is normalized in a scale from 1 to 4, and the thresholds are different from rule to rule). It leads to a different behavior for each rule: there are rules where only few violations lead to the minimum value and other rules where are allowed hundreds of violations.
* There are rules marked as Critical (this is a small subset of rules considered very urgent to fix, low values for these rules cause direct lowering of one or more KPIs) which pose a cap on the KPIs.

Sometimes only critical violations can be considered, but it is not said to be valid in any situation. Each time an application is analyzed, the distribution of the violations can be completely different. This landscape depends on the behavior of developers, on the technologies used, on the type of architectural choices they have made. For instance, violations could be related to rules not marked as critical, but in such a quantity as to compromise the quality of the application.

In addition, we must consider that each violation fixing effort depends on the violated rule: interventions on the very same object to correct a naming convention problem rather than a programming practice problem may take very different timings. In some cases, it may be necessary to rewrite entire portions of code or entire procedures, but not in others. For architectural issues, it may be necessary to intervene on many different components located even in different application layers.

_Which are the objects to correct, within the selected rule?_ For violations regarding the same rule we must choose the objects that are most used; in this way, we can guarantee a wider benefit across the application while keeping the effort low.

Given the complexity of the problem and the amount of data to handle, it is very difficult for human agents to manually generate good quality action plans. Even using automated algorithms based on top-down hierarchical techniques such as decision trees, or systems based on _a priori_ rating for rules, there is a strong risk of producing a poorly optimized course of action.

To provide a good Action Plan, you must consider all these factors together, with a holistic view.
This requires an Artificial Intelligence approach, and that’s what is done by the GAP Optimizer.

# 2. How It Works
The problem of finding the best action plan for an application can be considered a search problem in a huge space. Indeed, the number of possible subsets of violations for an application with N violations is 2^N (Cardinality of Power Set). This number is huge: if you mean that a medium-sized app could have more than 10.000 violations, it means: 2^10.000 .

The space where to find the optimal action plan is a multidimensional (N dimensions) and qualitative space (each violation is identified by the rule violated and the object that violates it: they are pure qualitative data). 

If we define a “Fitness” function for each action plan, the problem of finding the best action plan can be defined as the problem of finding the global maximum of this function.

![](https://github.com/CAST-Extend/com.castsoftware.uc.gap/blob/master/Fitness.png)

Even if the space is not Euclidean and the dimensions are more than two, we can imagine the candidate solutions of the problem as points on a surface, where the Y axis is the value of the fitness function. Every time we analyze a different application, we will have a totally different Fitness Landscape.

Following the genetic approach, each violation can be seen as a gene and the action plan as a genotype (DNA).

![](https://github.com/CAST-Extend/com.castsoftware.uc.gap/blob/master/DNA1.PNG)

Each violation is identified by the ID of the rule violated and the ID of the object violating the rule. A specific removal effort (in minutes) can be associated to each violation:

Vi = ( Rule ID , Object ID, Effort )

We start with a population of randomly generated action plans with a specific effort constraint (parameter):

E_AP= ∑E_i    (the effort of the action plan is the sum of the effort for removing each violation)

The AP in the initial population will be generated using the violations of the application found by CAST AIP for a specific snapshot. The random generator will select the violations uniformly in the violations statistic distribution. 
The AP will evolve at each generation using typical evolutionary operators (crossover and mutations), swapping the genes.

![](https://github.com/CAST-Extend/com.castsoftware.uc.gap/blob/master/DNA2.PNG)
 
At each generation only the best individuals will be crossed and their genes will be used for generating the individuals of the population of the next generation.

![](https://github.com/CAST-Extend/com.castsoftware.uc.gap/blob/master/DNA3.PNG)

The optimization criterion (Fitness Function), by which the best action plans are selected, can be defined in different ways:

Fitness=f(TQI,Security,Robustness,Efficiency,Changeability,Transferability,∑PRI,…)

Generally speaking, the Fitness function can be any combination of Business Factors, Risk Indexes, other KPIs, … An example of Fitness is the delta TQI that measures the impact on the Total Quality Index value caused by a specific Action Plan.

Across generations you'll get a population of high fitness individuals (Action Plans) who respect the constraint of effort set. Among these Action Plans we find the Maximum Fitness Individual according to the fitness criterion set. It will be the best solution found by the GA for the problem.

![](https://github.com/CAST-Extend/com.castsoftware.uc.gap/blob/master/best-fit.png)

This method is computationally heavy because it is needed to compute the fitness function (IE. The TQI) for each AP in the population at each generation, but this method is also powerful because it explores the space in parallel, starting from many different points uniformly distributed in space and then moving them exchanging information between them (like PSO methods) , in this case genetic information.

A Genetic Algorithm is probably the best way to explore such kind of space, consisting of many qualitative and multidimensional data, where traditional hierarchical methods fail. It avoids the local maximums where many methods fall, and leads to the fittest solution (if the population size and the number of generations are large enough).

Since the initial population is randomly generated, we could have a few different results on the same analysis data (this will happen more often if the population size and the number of generations are insufficient, less so if you give more resources to the algorithm).

The method suggested is a simple way, powerful and appealing, to find a good Action Plan in few minutes or even seconds, when the effort available is limited and there is no clear idea on how to use it.

Furthermore, it is highly scalable and works also for finding sub-optimal but good-enough solutions, when the size of the application and the number of violations are too big to have enough time and resources to find the very global maximum of the fitness function. Typically, a customer needs the best possible solution in a reasonable time: this is exactly what is done by this method.

# 3. How to use it
The Genetic Action Plan Optimizer provides both Graphical User Interface and Command Line Interface, for automation purposes.

## 3.1 The Graphical User Interface
The GUI is launched from GAP.exe file. It has a configuration file called GAP.exe.config.
After starting, it appears a connection form, where you must specify all the info needed for the connection to the central base where the application belongs:

![](https://github.com/CAST-Extend/com.castsoftware.uc.gap/blob/master/connection.png)

Pressing OK, it will be shown the main form of the tool:

![](https://github.com/CAST-Extend/com.castsoftware.uc.gap/blob/master/mainform.png)

The main parameters are:
* **Application**: name of the application already analyzed in CAST AIP.
* **Snapshot**: name of the snapshot of the application for which you need to generate the Action Plan.
* **Constraint**: kind of constraint that will be applied to the Action Plan.
At the moment only two types of constraint are allowed:
	* **Max Violations (amount)**: maximum number of violations that can be inserted in the AP.
	* **Max Effort (hours)**: maximum effort specified in hours for the AP.

* **Target Fitness**: objective of the optimization, it specifies the fitness function that evaluates the candidate solutions of the Genetic Algorithm. The allowed values are (each of them maximizes the impact of the action plan on the corresponding business factor):
	* **TQI**
	* **Security**
	* **Robustness**
	* **Efficiency**
	* **Changeability**
	* **Transferability**

The GA optimization method requires some additional settings:

* **Population Size**: the number of AP that the algorithm handles at each generation. The larger the population, the greater the chances of finding the global maximum overall the fitness function. The smaller the population, the less the calculations needed for each generation, the faster the speed.
* **Generation Limit**: maximum number of iterations (Generations) allowed by the GA. It should be enough to reach the maximum of fitness function.
* **Crossover Probability**: probability to cross the genes between two individuals selected from the population. It increases the climb speed of the algorithm.
* **Mutation Probability**: probability to mutate a gene in a genotype (AP) with another gene selected randomly from the violation scope of the algorithm.
* **Elitism**: percentage of individuals that will be selected as they are for the next generation. The selection starts from the individuals with higher fitness. It ensures monotone growing for the fitness function.
* **Termination Condition**: if the fitness function does not have any improvement for this number of generations, the algorithm will stop.

There is also the possibility to restrict the “Action Plan Scope”, from a dedicated panel:

![](https://github.com/CAST-Extend/com.castsoftware.uc.gap/blob/master/scope.png)

From this panel, you can see the total number of applied rules to the application, the number of rules with violations, the total number of violations in the selected module/s, the subset of critical violations and the value of the current TQI.

Below the number of violations that will be inserted in the AP Scope: these are the genes on which the individuals in the population will be built.

Below, there is on the left the tree view of the modules of the application, on the right the tree view of the Quality Model of the application: **Business Criteria -> Technical Criteria -> Quality Rules**. Below, for each rule, the list of violations. It is possible to exclude from the AP scope a single violation, all the violations for a specific rule or technical criteria, all the violations for one or more modules.
It is also possible save these exclusions and reload them from file (xml).

This is useful for excluding from the AP violations that are not considered significant or pertinent to the criterion chosen, or because they are considered as false positives.
If the AP Scope is too small, it will be impossible to build the population and as well to produce AP with an impact on the business criteria selected as fitness function.

If the constraint selected is the effort, it is mandatory to provide the “Fixing Efforts” from the dedicated panel:

![](https://github.com/CAST-Extend/com.castsoftware.uc.gap/blob/master/rules.png)

The list can be filtered on the rules that are violated from the selected application. The estimated average time for fixing a violation can be set for each violated rule. The best way to obtain it would be register the time needed for fixing directly from the developers, in many different cases, and then calculate the arithmetic average. In the absence of this information you can contact one or more SME of the language or technology concerned, based on their experience they can provide their estimate of the time required.

It is possible to save this efforts in a specific file (rules.xml) and then to reuse them for other applications and AP.
If a Rule contained in the Quality Model of the selected Central Base is not included in the rules.xml file, the effort is loaded from the Technical Debt parameters, based on the weight classification of the rule (see http://doc.castsoftware.com/display/DOC82/Technical+Debt+-+calculation+and+modification). Then it can be changed at will.
If the GAP.exe is launched without the rules.xml file, all the efforts are loaded form the Technical Debt parameters in the Central Base. Consider that these efforts are inaccurate, it is preferable to locate specific efforts for each rule.

When all options are set, pressing the button “Init”, It will be initialized a new random population:

![](https://github.com/CAST-Extend/com.castsoftware.uc.gap/blob/master/init.png)

Pressing the button “Run”, the evolution of the algorithm will start:

![](https://github.com/CAST-Extend/com.castsoftware.uc.gap/blob/master/run.png)

The upper graph shows the evolution of the fitness of the fittest individual across the generations: it is the “learning curve” of the algorithm.

The lower graph shows the fitness distribution inside the current population: every vertical bar is a different candidate solution (Action Plan) evaluated with the selected fitness criteria.
The graphs are updated in real time during the evolution of population at each generation.

It is possible to pause the evolution and resume it in every moment during the running, with the buttons “Pause” and “Resume”. Pressing again the button “Init” will produce a new initial random population.
When the running stops, it is possible to press the “Get Best-Fit AP” button to get the maximum fitness individual in the current population.

![](https://github.com/CAST-Extend/com.castsoftware.uc.gap/blob/master/best.png)

From the “Action Plan” form is possible to see the list of violations contained in the best-fit AP: ID and name of the rule violated, ID and full name of the object violating it, effort for fixing the violation. On the right are reported some global features of the AP: size (number of violations), fitness (impact on TQI), total effort. It is also possible to export the AP from here to the CAST dashboards (AED, CED) or save it to CSV file.

## 3.2 The Command Line Interface
The CLI is launched from GAP-CLI.exe file. It has a configuration file called GAP-CLI.exe.config.

![](https://github.com/CAST-Extend/com.castsoftware.uc.gap/blob/master/cli2.png)

The parameters are the same shown in the GUI, an example of command line is:

       GAP-CLI.exe -a "CASTWindowsService" -s "Computed on 201709291921" -d 20170930 -c "violations" -v 20 -l "log.txt" -o CSV -p "AP.csv"

The other settings and info needed by the algorithm must be specified in the configuration file (GAP-CLI.exe.config) in the GAP.Properties.Settings section:

        <GAP_CLI.Properties.Settings>
            <!-- name of the host running the CAST AIP DB -->
            <setting name="Server" serializeAs="String">
                <value>localhost</value>
            </setting>
            <!-- port of the host running the CAST AIP DB -->
            <setting name="Port" serializeAs="String">
                <value>2280</value>
            </setting>
            <!-- User for connecting CAST AIP DB -->
            <setting name="User" serializeAs="String">
                <value>operator</value>
            </setting>
            <!-- Password for connecting CAST AIP DB -->
            <setting name="Pw" serializeAs="String">
                <value>CastAIP</value>
            </setting>
            <!-- Maximum number of generation allowed by the GA -->
            <setting name="max_gen" serializeAs="String">
                <value>150</value>
            </setting>
            <!-- Probability to cross the genes between two AP selected from the population -->
            <setting name="crossoverProbability" serializeAs="String">
                <value>0.85</value>
            </setting>
            <!-- Probability to mutate a gene in a genotype (AP) -->
            <setting name="mutationProbability" serializeAs="String">
                <value>0.08</value>
            </setting>
            <!-- Percentage of AP that will be selected as they are for the next generation -->
            <setting name="elitismPercentage" serializeAs="String">
                <value>5</value>
            </setting>
            <!-- Number of generations without improvements in the fitness when the GA will stop -->
            <setting name="termCond" serializeAs="String">
                <value>20</value>
            </setting>
            <!-- Nhe number of individuls (AP) that the algorithm handles at each generation -->
            <setting name="pop_size" serializeAs="String">
                <value>200</value>
            </setting>
            <!-- Central Base in the CAST AIP DB for connection -->          
            <setting name="Schema" serializeAs="String">
                <value>aip824_central</value>
            </setting>
            <!-- User of CAST WS Rest API  -->
            <setting name="AED_user" serializeAs="String">
                <value>admin</value>
            </setting>
            <!-- Password of CAST WS Rest API  -->
            <setting name="AED_pw" serializeAs="String">
                <value>cast</value>
            </setting>
            <!-- URL of CAST WS Rest API, including domain. Leave empty if not available -->
            <setting name="AED_URL" serializeAs="String">
                <value>http://localhost:8180/CAST-AAD-AED/rest/AED</value>
            </setting>
            <!-- File containing the Rules-Effort associations  -->
            <setting name="RulesEffort" serializeAs="String">
                <value>rules.xml</value>
            </setting>
        </GAP_CLI.Properties.Settings>

The file containing the Rules-Effort associations has the following structure:

     <?xml version="1.0" standalone="yes"?>
      <DocumentElement>
       <Effort>
        <metric_id>3624</metric_id>
        <metric_name>Avoid uncommented Interfaces (C# .Net)</metric_name>
        <m_fix_effort>10</m_fix_effort>
       </Effort>
       <Effort>
        <metric_id>5142</metric_id>
        <metric_name>Avoid Programs with High Essential Complexity (Cobol)</metric_name>
        <m_fix_effort>15</m_fix_effort>
       </Effort>
       . . .
       . . .
      </DocumentElement>

The effort for each rule must be specified in minutes.
The file to provide any exclusions to be made on the GA scope is like this:

     <?xml version="1.0" encoding="utf-8"?>
      <Exclusions>
       <Module Name="CASTWindowsService full content" />
       <TecnicalCriteria Id="61013" />
       <Rule Id="7766" />
       <Rule Id="7768" />
       <Violation RuleId="3562" ObjectId="63542" />
       <Violation RuleId="3562" ObjectId="63544" />
       . . .
       . . .
      </Exclusions>

The Log file produced by the CLI shows firstly all the values for the parameters and settings provided, and then tracks all the steps done by the algorithm and the value of the best fitness at each generation:

         10/3/2017 10:44:31 AM GAP Started
         Parameters:
	         ApplicationName=CASTWindowsService
	         SnapshotName=Computed on 201709291921
	         SnapshotDate=20170930
	         ConstraintType=violations
	         ConstraintValue=20
	         FitnessCriteria=TQI
	         LogFilePath=log.txt
	         ExclusionsFilePath=exclusions.xml
	         OutputType=CSV
	         OutputFile=AP.csv
	         OutputMode=replace
         Settings:
	         server=localhost
	         port=2280
	         schema=aip824_central
	         user=operator
	         pop_size=200
	         max_gen=150
	         crossoverProbability=0.85
	         mutationProbability=0.08
	         elitismPercentage=5
	         termCond=20
	         rulesEffort=rules.xml
        10/3/2017 10:44:32 AM DB Helper created
        10/3/2017 10:44:32 AM Snapshot ID found: 9
        10/3/2017 10:44:32 AM Rules loaded
        10/3/2017 10:44:32 AM Violations loaded
        10/3/2017 10:44:32 AM Results loaded
        10/3/2017 10:44:32 AM Modules loaded
        10/3/2017 10:44:32 AM Current bf value= 2.81609313701933
        10/3/2017 10:44:32 AM QualityTree created
        10/3/2017 10:44:32 AM QualityTree evaluated
        10/3/2017 10:44:32 AM Exclusions applied
        10/3/2017 10:44:32 AM GA created
        10/3/2017 10:44:32 AM GA started...
        10/3/2017 10:44:32 AM Gen 0 : BestFit = 2.91796687959617
        10/3/2017 10:44:32 AM Gen 1 : BestFit = 2.91796687959617
        10/3/2017 10:44:32 AM Gen 2 : BestFit = 2.92764265600999
        10/3/2017 10:44:32 AM Gen 3 : BestFit = 2.94255224025616
        10/3/2017 10:44:32 AM Gen 4 : BestFit = 2.97586469027358
        10/3/2017 10:44:32 AM Gen 5 : BestFit = 2.98599850467715
        10/3/2017 10:44:32 AM Gen 6 : BestFit = 2.99114282944565
        10/3/2017 10:44:32 AM Gen 7 : BestFit = 2.99387676576791
        10/3/2017 10:44:32 AM Gen 8 : BestFit = 2.99538329703066
        10/3/2017 10:44:32 AM Gen 9 : BestFit = 3.0065389285378
        10/3/2017 10:44:32 AM Gen 10 : BestFit = 3.0065389285378
        10/3/2017 10:44:32 AM Gen 11 : BestFit = 3.0065389285378
        10/3/2017 10:44:32 AM Gen 12 : BestFit = 3.01063634561022
        10/3/2017 10:44:32 AM Gen 13 : BestFit = 3.01063634561022
        10/3/2017 10:44:32 AM Gen 14 : BestFit = 3.01063634561022
        10/3/2017 10:44:32 AM Gen 15 : BestFit = 3.01075335958177
        10/3/2017 10:44:32 AM Gen 16 : BestFit = 3.01075335958177
        10/3/2017 10:44:32 AM Gen 17 : BestFit = 3.01509190658722
        10/3/2017 10:44:32 AM Gen 18 : BestFit = 3.02276363535021
        10/3/2017 10:44:32 AM Gen 19 : BestFit = 3.02276363535021
        10/3/2017 10:44:32 AM Gen 20 : BestFit = 3.02276363535021
        10/3/2017 10:44:32 AM Gen 21 : BestFit = 3.02276363535021
        10/3/2017 10:44:32 AM Gen 22 : BestFit = 3.02276363535021
        10/3/2017 10:44:33 AM Gen 23 : BestFit = 3.03359099927933
        10/3/2017 10:44:33 AM Gen 24 : BestFit = 3.03391926685734
        10/3/2017 10:44:33 AM Gen 25 : BestFit = 3.03391926685734
        10/3/2017 10:44:33 AM Gen 26 : BestFit = 3.03391926685734
        10/3/2017 10:44:33 AM Gen 27 : BestFit = 3.03593387384662
        10/3/2017 10:44:33 AM Gen 28 : BestFit = 3.03593387384662
        10/3/2017 10:44:33 AM Gen 29 : BestFit = 3.03668008528335
        10/3/2017 10:44:33 AM Gen 30 : BestFit = 3.03808437719919
        10/3/2017 10:44:33 AM Gen 31 : BestFit = 3.03808437719919
        10/3/2017 10:44:33 AM Gen 32 : BestFit = 3.03866412228917
        10/3/2017 10:44:33 AM Gen 33 : BestFit = 3.03888045879104
        10/3/2017 10:44:33 AM Gen 34 : BestFit = 3.03888045879104
        10/3/2017 10:44:33 AM Gen 35 : BestFit = 3.03891059002983
        10/3/2017 10:44:33 AM Gen 36 : BestFit = 3.03891059002983
        10/3/2017 10:44:33 AM Gen 37 : BestFit = 3.03891059002983
        10/3/2017 10:44:33 AM Gen 38 : BestFit = 3.04254538669216
        10/3/2017 10:44:33 AM Gen 39 : BestFit = 3.04334146828401
        10/3/2017 10:44:33 AM Gen 40 : BestFit = 3.04334146828401
        10/3/2017 10:44:33 AM Gen 41 : BestFit = 3.04334146828401
        10/3/2017 10:44:33 AM Gen 42 : BestFit = 3.04334146828401
        10/3/2017 10:44:33 AM Gen 43 : BestFit = 3.04334146828401
        10/3/2017 10:44:33 AM Gen 44 : BestFit = 3.04334146828401
        10/3/2017 10:44:33 AM Gen 45 : BestFit = 3.04334146828401
        10/3/2017 10:44:33 AM Gen 46 : BestFit = 3.04334146828401
        10/3/2017 10:44:33 AM Gen 47 : BestFit = 3.04334146828401
        10/3/2017 10:44:33 AM Gen 48 : BestFit = 3.04334146828401
        10/3/2017 10:44:33 AM Gen 49 : BestFit = 3.04334146828401
        10/3/2017 10:44:33 AM Gen 50 : BestFit = 3.04334146828401
        10/3/2017 10:44:33 AM Gen 51 : BestFit = 3.04334146828401
        10/3/2017 10:44:33 AM Gen 52 : BestFit = 3.04334146828401
        10/3/2017 10:44:33 AM Gen 53 : BestFit = 3.04334146828401
        10/3/2017 10:44:33 AM Gen 54 : BestFit = 3.04520812569773
        10/3/2017 10:44:33 AM Gen 55 : BestFit = 3.04535607527329
        10/3/2017 10:44:33 AM Gen 56 : BestFit = 3.04535607527329
        10/3/2017 10:44:33 AM Gen 57 : BestFit = 3.04535607527329
        10/3/2017 10:44:33 AM Gen 58 : BestFit = 3.04535607527329
        10/3/2017 10:44:33 AM Gen 59 : BestFit = 3.04535607527329
        10/3/2017 10:44:33 AM Gen 60 : BestFit = 3.04535607527329
        10/3/2017 10:44:33 AM Gen 61 : BestFit = 3.04535607527329
        10/3/2017 10:44:33 AM Gen 62 : BestFit = 3.04535607527329
        10/3/2017 10:44:33 AM Gen 63 : BestFit = 3.04535607527329
        10/3/2017 10:44:33 AM Gen 64 : BestFit = 3.04535607527329
        10/3/2017 10:44:33 AM Gen 65 : BestFit = 3.04535607527329
        10/3/2017 10:44:33 AM Gen 66 : BestFit = 3.04535607527329
        10/3/2017 10:44:33 AM Gen 67 : BestFit = 3.04535607527329
        10/3/2017 10:44:33 AM Gen 68 : BestFit = 3.04535607527329
        10/3/2017 10:44:33 AM Gen 69 : BestFit = 3.04535607527329
        10/3/2017 10:44:33 AM Gen 70 : BestFit = 3.04535607527329
        10/3/2017 10:44:33 AM Gen 71 : BestFit = 3.04535607527329
        10/3/2017 10:44:33 AM Gen 72 : BestFit = 3.04535607527329
        10/3/2017 10:44:33 AM Gen 73 : BestFit = 3.04535607527329
        10/3/2017 10:44:33 AM Gen 74 : BestFit = 3.04535607527329
        10/3/2017 10:44:33 AM Gen 75 : BestFit = 3.04535607527329
        10/3/2017 10:44:33 AM Gen 76 : BestFit = 3.04535607527329
        10/3/2017 10:44:33 AM Evolution Completed
        10/3/2017 10:44:33 AM BestFit AP found
        10/3/2017 10:44:33 AM AP Saved to file: AP.csv

## 3.3 Known Limitations

* Only CSS2 is supported as CAST DBMS.
* For applications splitted in multiple modules, the GAP calculates the KPIs always with the consolidation mode "Full Application" even if the settings in the assessment model in CMS are different.
* The estimation of KPIs made by the GAP does not take account of the impact of AP to "Quality Distribution" metrics.

# 4. References

* **“An Introduction to Genetic Algorithms”** Melanie Mitchell - A Bradford Book. The MIT Press. Cambridge, Massachusetts - London, England. Fifth printing, 1999
* **“Artificial Intelligence: A Modern Approach, 3rd Edition”** Stuart Russell, Peter Norvig, Google Inc. – Pearson 2010

# 5. CAST AIP Compatibility
The following table gives the list of CAST AIP configurations where the Extension has been implemented:

* CAST AIP 8.1.x
* CAST AIP 8.2.x

**Note:** **Only CSS2 DBMS is supported.**

# 6. Prerequisites & Installation

## 6.1 Prerequisites
The following table gives the complete list of technical prerequisites to be met before installing the Extension:

* An installation of any compatible release of CAST AIP (see table above)
* MS .Net Framework v.4.5.2
* CAST AED Installation (optional) : for calling the Rest API (Required only for Rules Description)

## 6.2 Installation Instructions
The extension is ready after installing it with CAST Extension Downloader. You will find the tool's executables in the extensions folder (Normally set at: C:\ProgramData\CAST\CAST\Extensions\com.castsoftware.uc.gap, see CAST AIP Documentation).
