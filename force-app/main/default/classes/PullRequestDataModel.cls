public class PullRequestDataModel {
    public static final String TABLE_NAME = 'GitHub Pull Requests';

	public static DataSource.Table buildTable(){
                List<DataSource.Column> columns = new List<DataSource.Column>();
                columns.add(DataSource.Column.text('ExternalId', 255));

                columns.add(DataSource.Column.url('Url'));

                columns.add(DataSource.Column.boolean('Draft'));

                columns.add(DataSource.Column.number('Number', 16, 0));

                columns.add(DataSource.Column.text('State'));
                columns.add(DataSource.Column.text('Title'));
                columns.add(DataSource.Column.text('Body'));

                columns.add(DataSource.Column.text('Body'));


                //TODO change to date fields
                columns.add(DataSource.Column.text('CreatedDate'));
                columns.add(DataSource.Column.text('UpdatedDate'));
                columns.add(DataSource.Column.text('ClosedDate'));
                columns.add(DataSource.Column.text('MergedDate'));

                columns.add(DataSource.Column.boolean('Merged'));

                return DataSource.Table.get(TABLE_NAME, 'ExternalId', columns);
        } 
        
        private static List<Map<String, Object>> getPullRequests(HttpResponse response){
                List<Map<String, Object>> pullRequests = new List<Map<String, Object>>();
                for (Object item : (List<Object>)JSON.deserializeUntyped(response.getBody())) {
                        pullRequests.add(buildPRFromJson(item));
                }
                return pullRequests;
        }

        private static Map<String, Object> buildPRFromJson(Object item){
                Map<String, Object> repo = (Map<String, Object>)item;
                repo.put('ExternalId', repo.get('id'));

                repo.put('Name', repo.get('name'));
                repo.put('Description', repo.get('description'));
                repo.put('Stars', repo.get('stargazers_count'));

                repo.put('Private', repo.get('private'));
                repo.put('Fork', repo.get('fork'));

                repo.put('DisplayUrl', repo.get('html_url'));
                repo.put('LanguagesUrl', repo.get('languages_url'));

                repo.put('Language', repo.get('language'));

                //TODO make the transformation
                repo.put('CreatedDate', repo.get('created_at'));
                repo.put('UpdatedDate', repo.get('updated_at'));
                repo.put('LastPushedDate', repo.get('pushed_at'));

                repo.put('Archived', repo.get('archived'));
                repo.put('Disabled', repo.get('disabled'));

                repo.put('OpenIssuesCount', repo.get('open_issues_count'));

                repo.put('License', repo.get('license'));

                repo.put('Size', repo.get('size'));
                repo.put('TotalForks', repo.get('forks_count'));
                repo.put('Watchers', repo.get('watchers_count'));

                return repo;
	} 

	public static DataSource.TableResult handleQuery(DataSource.QueryContext queryContext, String user, String repositoryName){
                Http httpProtocol = new Http();
                HttpRequest request = new HttpRequest();
                //TODO
                String url = 'https://api.github.com/repos/' + user + '/' + repositoryName + '/pulls';
                request.setEndpoint(url);
                request.setMethod('GET');
                HttpResponse response = httpProtocol.send(request);

                try {
                        // Note: If a 4xx status code occurs when querying the GitHub API, deserializeUntyped()
                        // will simply return a Map<Objects> instead of a List<Map<String, Object>>, resulting in
                        // a runtime error.
                        List<Map<String, Object>> repositories = getPullRequests(response);
                        List<Map<String, Object>> repos = DataSource.QueryUtils.process(queryContext,repositories );
                        DataSource.TableResult tableResult = DataSource.TableResult.get(queryContext, repos);
                        
                        return tableResult;
                
                } catch (Exception e) {
                        throw new IllegalArgumentException('Bad response. Response: ' + response.getBody()
                        + ', Status = ' + response.getStatus()
                        + ', Status code = ' + response.getStatusCode()
                        + ', Request: ' + request.getEndpoint(), e);
                }       
	} 
}