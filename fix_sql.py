import sys

def fix_sql_content(sql_content):
    # Temporarily replace $$ with a unique placeholder to protect it
    # This is a very unlikely string to appear in SQL content
    fixed_content = sql_content.replace("$$", "__DOLLAR_DOLLAR_PLACEHOLDER__")

    # Replace all occurrences of '' with '
    fixed_content = fixed_content.replace("''", "'")

    # Revert the placeholder back to $$
    fixed_content = fixed_content.replace("__DOLLAR_DOLLAR_PLACEHOLDER__", "$$")

    return fixed_content

if __name__ == "__main__":
    sql_content = sys.stdin.read()
    modified_content = fix_sql_content(sql_content)
    sys.stdout.write(modified_content)