#!/usr/bin/env python3
"""
Create an fzf-optimized file for searching Nerd Fonts icons.
Format: ICON NAME DESCRIPTION CATEGORY CODEPOINT
"""

def main():
    input_file = "nerdfonts_cheatsheet.txt"
    output_file = "icons_fzf.txt"
    
    try:
        with open(input_file, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        # Skip header lines (first 4 lines)
        icon_lines = lines[4:]
        
        fzf_entries = []
        processed_count = 0
        
        print(f"Processing {len(icon_lines)} icon entries for fzf...")
        
        for line in icon_lines:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
                
            # Parse format: GLYPH_NAME | CODEPOINT | DESCRIPTION | CATEGORY
            parts = [part.strip() for part in line.split('|')]
            if len(parts) < 3:
                continue
                
            # Extract components
            glyph_name = parts[0]
            codepoint = parts[1]
            description = parts[2] if len(parts) > 2 else "Unknown"
            category = parts[3] if len(parts) > 3 else "Other"
            
            # Convert hex codepoint to unicode character
            try:
                # Remove any 'nf-' prefix and convert hex to int
                clean_codepoint = codepoint.lower().replace('0x', '').strip()
                unicode_int = int(clean_codepoint, 16)
                rendered_icon = chr(unicode_int)
                
                # Create searchable name variations
                # Remove 'nf-' prefix and convert underscores to spaces for better searching
                searchable_name = glyph_name.replace('nf-', '').replace('_', ' ').replace('-', ' ')
                
                # Also create keyword variations
                keywords = []
                keywords.extend(searchable_name.split())
                keywords.extend(description.lower().split())
                keywords.append(category.lower())
                
                # Remove duplicates and join
                unique_keywords = list(set(keywords))
                keyword_string = ' '.join(unique_keywords)
                
                # Format for fzf: ICON NAME DESCRIPTION [CATEGORY] U+CODE | searchable_keywords
                fzf_entry = f"{rendered_icon} {searchable_name} - {description} [{category}] U+{clean_codepoint.upper()} | {keyword_string}"
                fzf_entries.append(fzf_entry)
                processed_count += 1
                
            except (ValueError, OverflowError) as e:
                print(f"Warning: Could not process {glyph_name} with codepoint {codepoint}: {e}")
                continue
        
        # Write to output file
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write("# Nerd Fonts Icons - FZF Optimized\n")
            f.write("# Usage: cat icons_fzf.txt | fzf --ansi\n")
            f.write("# Or: fzf < icons_fzf.txt\n")
            f.write(f"# Total icons: {processed_count}\n")
            f.write("\n")
            
            for entry in fzf_entries:
                f.write(entry + '\n')
        
        print(f"Successfully created fzf file with {processed_count} icons: {output_file}")
        
        # Create an even simpler version for basic usage
        create_simple_fzf_file(fzf_entries, processed_count)
        
    except FileNotFoundError:
        print(f"Error: Could not find input file '{input_file}'")
        return 1
    except Exception as e:
        print(f"Error: {e}")
        return 1
    
    return 0

def create_simple_fzf_file(entries, total_count):
    """Create a simpler version with just icon, name, and basic info"""
    simple_file = "icons_simple.txt"
    
    with open(simple_file, 'w', encoding='utf-8') as f:
        f.write("# Nerd Fonts Icons - Simple Format\n")
        f.write("# Format: ICON name description [category]\n")
        f.write(f"# Total icons: {total_count}\n")
        f.write("# Usage: fzf < icons_simple.txt\n")
        f.write("\n")
        
        for entry in entries:
            # Extract just the part before the | for simpler display
            simple_entry = entry.split(' | ')[0]
            f.write(simple_entry + '\n')
    
    print(f"Simple format created: {simple_file}")

if __name__ == "__main__":
    exit(main())