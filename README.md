# n8n_obsidian

Build a local n8n workflow that collects links from X and saves them into an Obsidian vault as Markdown notes.

## Goal

Create a local automation:
1. Pull recent posts from X.
2. Extract URLs from those posts.
3. Write each URL into your Obsidian vault.

## Prerequisites

1. Install Node.js 20+.
2. Install n8n locally:
   ```bash
   npm install -g n8n
   ```
3. Have an Obsidian vault on your machine (example path: `/Users/<you>/Documents/ObsidianVault`).
4. Have access to X data (API key/bearer token, or another feed source you control).

## Run n8n Locally

1. Start n8n:
   ```bash
   n8n start
   ```
2. Open `http://localhost:5678`.
3. Create a new workflow named `X Links -> Obsidian`.

## Build the Workflow

Add these nodes in order:

1. `Schedule Trigger`
   - Run every 15 minutes (or your preferred interval).

2. `HTTP Request` (Get posts from X)
   - Method: `GET`
   - URL (example): `https://api.x.com/2/users/<USER_ID>/tweets?max_results=10&tweet.fields=entities,created_at`
   - Auth: Bearer Token
   - Response format: JSON

3. `Code` (Extract links)
   - Use this code:
   ```javascript
   const out = [];
   const tweets = $json.data ?? [];
   for (const tweet of tweets) {
     const urls = tweet.entities?.urls ?? [];
     for (const u of urls) {
       out.push({
         json: {
           tweet_id: tweet.id,
           created_at: tweet.created_at,
           x_url: `https://x.com/i/web/status/${tweet.id}`,
           link: u.expanded_url || u.url,
         },
       });
     }
   }
   return out;
   ```

4. `Code` (Format note content)
   - Use this code:
   ```javascript
   const today = new Date().toISOString().slice(0, 10);
   return items.map((item, idx) => {
     const { link, x_url, created_at } = item.json;
     item.json.fileName = `${today}-x-link-${idx + 1}.md`;
     item.json.content = `# X Link\n\n- URL: ${link}\n- Source: ${x_url}\n- Posted: ${created_at}\n`;
     return item;
   });
   ```

5. `Write Files to Disk`
   - File Path: `/Users/<you>/Documents/ObsidianVault/Inbox/{{$json.fileName}}`
   - Data to Write: `{{$json.content}}`
   - Append: `false`

## Test and Activate

1. Click `Execute workflow`.
2. Confirm markdown files appear in your vault `Inbox` folder.
3. Open Obsidian and verify the notes.
4. Click `Activate` in n8n.

## Optional Improvements

1. Add a dedupe step (store processed tweet IDs in `Data Store`).
2. Append all links into one daily file instead of one file per link.
3. Add tags/frontmatter for better Obsidian search.
