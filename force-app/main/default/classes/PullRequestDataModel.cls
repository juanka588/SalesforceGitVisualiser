public class PullRequestDataModel {
    public static final String TABLE_NAME = 'GitHub Pull Requests';
    
    public static DataSource.Table buildTable(){
        List<DataSource.Column> columns = new List<DataSource.Column>();
        // mandatory fields
        columns.add(DataSource.Column.text('ExternalId', 255));
        columns.add(DataSource.Column.url('DisplayUrl'));
        
        columns.add(DataSource.Column.boolean('Draft'));
        
        columns.add(DataSource.Column.number('Number', 16, 0));
        
        columns.add(DataSource.Column.text('State'));
        columns.add(DataSource.Column.text('Title'));
        columns.add(DataSource.Column.text('Body'));
        
        columns.add(DataSource.Column.text('Owner'));
        columns.add(DataSource.Column.text('OwnerId'));
        
        columns.add(DataSource.Column.text('CreatedDate'));
        columns.add(DataSource.Column.text('UpdatedDate'));
        columns.add(DataSource.Column.text('ClosedDate'));
        columns.add(DataSource.Column.text('MergedDate'));
        
        columns.add(DataSource.Column.boolean('Merged'));

        //parent id
        columns.add(DataSource.Column.text('RepoName'));
        
        return DataSource.Table.get(TABLE_NAME, 'Number', columns);
    } 
    
    //Test Only
    public static List<Map<String, Object>> getPullRequests(String content){
        if (content == null || ''.equals(content)) {
            return new List<Map<String,Object>>();
        }
        List<Map<String, Object>> pullRequests = new List<Map<String, Object>>();
        for (Object item : (List<Object>)JSON.deserializeUntyped(content)) {
            pullRequests.add(buildPRFromJson(item));
        }
        return pullRequests;
    }
    
    private static Map<String, Object> buildPRFromJson(Object item){
        Map<String, Object> pullRequest = (Map<String, Object>)item;
        pullRequest.put('ExternalId', pullRequest.get('id'));

        pullRequest.put('DisplayUrl', pullRequest.get('url'));

        pullRequest.put('Draft', pullRequest.get('draft'));

        pullRequest.put('Number', pullRequest.get('number'));

        pullRequest.put('State', pullRequest.get('state'));
        pullRequest.put('Title', pullRequest.get('title'));
        pullRequest.put('Body', pullRequest.get('body'));


        pullRequest.put('CreatedDate', DataUtils.transformDate(pullRequest.get('created_at')));
        pullRequest.put('UpdatedDate', DataUtils.transformDate(pullRequest.get('updated_at')));
        pullRequest.put('ClosedDate', DataUtils.transformDate(pullRequest.get('closed_at')));
        pullRequest.put('MergedDate', DataUtils.transformDate(pullRequest.get('merged_at')));


        pullRequest.put('Merged', pullRequest.get('merged'));

        Map<String,Object> user=(Map<String,Object>)pullRequest.get('user');
        pullRequest.put('Owner', user.get('login'));
        pullRequest.put('OwnerId', user.get('id'));


        Map<String,Object> base=(Map<String,Object>)pullRequest.get('base');
        Map<String,Object> repo=(Map<String,Object>)base.get('repo');
        pullRequest.put('RepoName', repo.get('name'));
        
        return pullRequest;
    } 

    public static DataSource.TableResult handleQuery(DataSource.QueryContext queryContext){
        //TODO
       return handleQuery(queryContext,'apache','lucene-solr');
    } 
    
    public static DataSource.TableResult handleQuery(DataSource.QueryContext queryContext, String user, String repositoryName){
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        //TODO
        String url = 'https://api.github.com/repos/' + user + '/' + repositoryName + '/pulls?state=all';
        request.setEndpoint(url);
        request.setMethod('GET');
        HttpResponse response = httpProtocol.send(request);
        
        try {
            // Note: If a 4xx status code occurs when querying the GitHub API, deserializeUntyped()
            // will simply return a Map<Objects> instead of a List<Map<String, Object>>, resulting in
            // a runtime error.
            List<Map<String, Object>> pullRequests = getPullRequests(response.getBody());
            List<Map<String, Object>> prs = DataSource.QueryUtils.process(queryContext, pullRequests);
            DataSource.TableResult tableResult = DataSource.TableResult.get(queryContext, prs);
            
            return tableResult;
            
        } catch (Exception e) {
            throw new IllegalArgumentException('Bad response. Response: ' + response.getBody()
                                               + ', Status = ' + response.getStatus()
                                               + ', Status code = ' + response.getStatusCode()
                                               + ', Request: ' + request.getEndpoint(), e);
        }       
    } 
}
