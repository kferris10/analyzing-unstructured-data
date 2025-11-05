
import os
import json
import anthropic
import pandas as pd
import polars as pl

# load the user's anthropic key
# I keep my stored as an environment variable
def get_anthropic_key():
    return os.environ['CLAUDE_PERSONAL']

# my instructions for claude to analyze
def get_prompt_system(path): 
    with open(path, encoding="utf-8") as f:
        prompt_system = f.read()
    return prompt_system

# the data to pass to Claude
def get_prompt_user(name, tldr, summary): 
    prompt = f"""
    Analyze this scouting report of {name}.

    <tldr>
    **TLDR**:
    {tldr}
    </tldr>

    <summary>
    **Summary**:
    {summary}
    </summary>
    """

    return prompt

# wrapper to send data to Claude for analysis
def query_claude(user_prompt, 
                 system_prompt, 
                 model="claude-sonnet-4-5-20250929", 
                 max_tokens=8000, 
                 temperature=0.2):
    """Query Claude with a user prompt and system prompt"""
    # Claude connections
    ANTHROPIC_API_KEY=get_anthropic_key()
    client = anthropic.Anthropic(api_key=ANTHROPIC_API_KEY) 
    
    # Call Claude API
    message = client.messages.create(
        model=model,
        max_tokens=max_tokens,  
        temperature=temperature,
        system=system_prompt,
        messages=[{"role": "user", "content": [{"type": "text", "text": user_prompt}]}]
    )

    # Extract the Claude response
    response_text = message.content[0].text
    # Remove the ```json wrapper if present - Claude sometimes adds this
    if response_text.startswith('```json'):
        response_text = response_text.replace('```json\n', '').replace('\n```', '')

    return response_text

def process_claude_response(claude_response): 
    # Parse JSON (Claude often returns a Python-style string)
    try:
        # If Claude returns JSON-like Python dict string, use json.loads safely
        if isinstance(claude_response, str):
            json_data = json.loads(claude_response)
        elif isinstance(claude_response, dict):
            json_data = claude_response
        else:
            raise ValueError("Unexpected Claude response type")
    except json.JSONDecodeError as e:
        print(f"Error parsing JSON: {e}")
        print(f"Raw response: {claude_response}")
        return None

    # Sanity check
    if "players" not in json_data:
        raise KeyError("Expected 'players' key in Claude response")

    rows = []
    for player in json_data["players"]:
        # Flatten top-level player data
        player_name = player.get("player_name")
        traits = player.get("traits", {})
        summary = player.get("overall_summary")
        notes = player.get("processing_notes")

        # Filter out null traits if desired
        filtered_traits = {
            k: v for k, v in traits.items()
            if v and v.get("mentioned")
        }

        rows.append({
            "player_name": player_name,
            "overall_summary": summary,
            "processing_notes": notes,
            "traits_json": filtered_traits
        })

    df = pd.DataFrame(rows)
    return df

# wrapper function to iterate through a bunch of inputs, passing each to claude
def process_batch(data: pl.DataFrame, prompt_system: str):
    # info
    n_rows = data.height
    print(f"  {n_rows} Rows to process")

    # iteratively pass data to claude
    result = []
    for idx, row in enumerate(data.iter_rows(named=True)):
        print(f"Processing row {idx+1} of {n_rows}...")
        player_name_i = row["player"]
        tldr_i = row["tldr"]
        summary_i = row["summary"]

        # query claude
        print("Constructing prompt for player:", player_name_i)
        prompt_i = get_prompt_user(player_name_i, tldr_i, summary_i)
        print("Querying Claude AI for report analysis")
        response_i = query_claude(prompt_i, prompt_system)
        print("Processing Claude response")
        result_i = process_claude_response(response_i)
        print("Analysis complete")
        result.append(result_i)

    result = pd.concat(result, ignore_index=True)
    result = pl.from_pandas(result)
    return result