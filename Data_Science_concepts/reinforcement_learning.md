# Takeout-Menu problem - self-reinforcing agent model

Also known as the multi-armed-bandit problem
https://en.wikipedia.org/wiki/Multi-armed_bandit 


## General Problem setup: 
- how best to iteratively allocate resources to maximise some payoff over time
- finite number of assignments/allocations that can be made each period 
- possible allocations >> actual allocations per period 
- every period yields information in the form of actual payoffs from allocations made 


## Details of the Takeout-Menu problem statement: 
- after moving into a new apartment with your friend, a new Chinese takeout restaurant opens up, just a 7 min walk down the street
    * target for allocating resources 
    * accessible, minor friction to sample 
    * lack of detailed prior knowledge 
- the menu is huge, roughly 100 items, and deals/specials that might shift and/or rotate seasonally 
- room in your budget and stomaches only allows 2-4 items to be enjoyed each Wednesday night
- with each round of sampling, information is gained about the value yielded from those choices, which can guide future choices


* a systematic/exhaustive search for optima before picking a strategy is impractical (3-6 months of randomly ordering before being able to determine an optimal strategy)
* perfect/complete information can never be gathered before the underlying environment/options change 
* in some comparable scenarios, the act of sampling/selecting can change the available choices for the next round (meaning that more aggressive/rapid sampling will also never yield complete/perfect information) 

- with limited information and finite resources in your weekly takeout budget, you want to get the best value from this restaurant 



## Simulation Setup


