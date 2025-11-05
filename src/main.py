
import polars as pl
from utils_claude_api import process_batch, get_prompt_system

system_prompt = get_prompt_system("prompt-system.md")

def main(): 

    print("Loading Longenhagen reports")
    df = pl.read_csv("data/longenhagen.csv")
    df_hitters = df.filter(pl.col("f_hit").is_not_null())
    print(f"  {df_hitters.height} Hitters found, processing with Claude")
    df_processed = process_batch(df_hitters, system_prompt)

    print(f"Processing complete, saving {df_processed.height} results")
    df_processed.write_json("data/longenhagen-structured.json")



if __name__ == "__main__":
    main()
