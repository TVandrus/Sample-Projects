
# parameters

t_start = 1;
t_delta = 1;
t_end = 200;

n_agent = 500
n_step_sample = 20


# setup/configuration 

using DuckDB, DataFrames

db = DBInterface.connect(DuckDB.DB)

agent_ids = "agent_" .* lpad.(1:n_agent, 4, "0");

agents = DataFrame(
    "id" => agent_ids, 
    "skill" => rand(0:0.1:1, n_agent)
); 
prior_estimates = DataFrame(
    "id" => agent_ids,
    "alpha" => 1, 
    "beta" => 1, 
    "estimate" => 0.5
); 

DuckDB.register_data_frame(db, agents, "agents")
DuckDB.register_data_frame(db, prior_estimates, "prior_init")
DBInterface.execute(db, "drop table if exists priors;")
DBInterface.execute(db, "create table priors as select  * from prior_init")
DBInterface.execute(db, "drop table if exists outcomes;")
DBInterface.execute(db, "create table outcomes (t int, score decimal)")


# simulation loop 
# add noise to outcome/scoring
for t in t_start:t_delta:t_end 
    @debug "iteration $t"
    sampled_agents = DataFrame(DBInterface.execute(db, """
        select agents.id, 
            agents.skill >= 0.7 as success, 
            agents.skill < 0.7 as fail,
            agents.skill, 
            random() * estimate as sample 
        from priors 
            join agents on agents.id = priors.id
        order by sample desc
        limit $(n_step_sample) 
    ;"""))
    DuckDB.register_data_frame(db, sampled_agents, "trial")
    DBInterface.execute(db, """
        insert into outcomes
        select $(t) as t, sum(success::int) as successes 
        from trial
    ;""")
    DBInterface.execute(db, """
        update priors 
        set alpha = alpha + 1
        from trial 
        where trial.id = priors.id and trial.success 
    ;""")
    DBInterface.execute(db, """
        update priors 
        set beta = beta + 1
        from trial 
        where trial.id = priors.id and trial.fail 
    ;""")
    DBInterface.execute(db, """
        update priors 
        set estimate = alpha / (alpha + beta)
    ;""")
end


# check results 

DataFrame(DBInterface.execute(db, """
select agents.id, 
    agents.skill, 
    priors.estimate, 
    priors.alpha, 
    priors.beta 
from priors 
    join agents on agents.id = priors.id
where alpha + beta > 2
order by skill desc 
;"""))

# max possible score 
n_step_sample * (t_end - t_start)

# actual realized score
DataFrame(DBInterface.execute(db, """
select sum(score) as overall_actual
from outcomes 
;"""))
DataFrame(DBInterface.execute(db, """
select avg(score) as initial_avg 
from outcomes 
where t <= 10 
;"""))
DataFrame(DBInterface.execute(db, """
select avg(score) as late_average 
from outcomes
where t >= 180 
;"""))



