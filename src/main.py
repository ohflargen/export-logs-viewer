import dash
from dash import dcc, html, dash_table
import pandas as pd
from google.cloud import bigquery

app = dash.Dash(__name__)
server = app.server

# BigQuery client
client = bigquery.Client()

# BigQuery query
query = """
    SELECT runID, runType, startDate, endDate, app, bucket, environment, filePath, site, predDate
    FROM `aif-usr-p-itaia3i-98be.a3i_logs.exports`
"""

# Execute the query and load the results into a pandas DataFrame
df = client.query(query).to_dataframe()

app.layout = html.Div([
    html.H1(children='BigQuery Export Logs Viewer', style={'textAlign':'center'}),
    dash_table.DataTable(
        id='table',
        columns=[{"name": i, "id": i} for i in df.columns],
        data=df.to_dict('records'),
        sort_action="native",
        filter_action="native",
        page_size=20,
        style_table={'overflowX': 'auto'},
        style_cell={
            'height': 'auto',
            'whiteSpace': 'normal'
        },
    )
])

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8050)
