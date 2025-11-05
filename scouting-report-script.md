

# Scouting Analysis Script

> You are a baseball scouting analyst. Below is a scouting report on Brewers prospect Jesus Made. Tag whether the report mentions any of the following characteristics about Made. Tag only based on the report below, do not use any other information you know that is specific to Made. If the report does mention a characteristic, evaluate whether it mentions that characteristic as a positive or negative using the S-Tier:D-Tier ranking. Do not include a tiered ranking if the report simply mentions the characteristic but doesn't evaluate it as a positive or negative bat speed swing plane body type physical growth potentional twitchniess and/or reaction times defensive instincts waist height

Repeat for a couple players

> Considering these reports and your general knowledge of baseball scouting, what are other traits that you think might be relevant to evaluate? Provide a full list, consider position players only. I'm not interested in pitcher traits

> I would like to analyze large numbers of scouting reports via the API. Create a system prompt I can use to analyze these data following these instructions and evaluating each of the traits outlined here. The prompt should have the following structure. Tag each component using XML tags 

1. Task: high-level instructions 
2. Background: any background info to include on the task 
3. Description: Detailed description of what to do, traits to analyze, etc 
4. Format: I would like the result to be returned as appropriately formatted JSON, with a node for each player analyzed and key-value pairs for each attribute which is I dentified and the pair. 
5. Examples: include a couple examples from the reports in this discussion. Make sure to tag all the relevant traits, not just the ones I initially asked for 6. Conclusion: reiterate the high-level instructions, stress the importance of following details precisely, thinking critically about the report when analyzing, and providing the precise output format

Analyze a new player using this prompt

