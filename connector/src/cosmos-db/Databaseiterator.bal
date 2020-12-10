class DatabaseIterator {

    private stream<Database> st;
    private int count;
    private Headers headers;

    function init(stream<Database> st,int count,Headers headers) {
        self.st = st;
        self.count = count;
        self.headers = headers;
    }

    public function getStream() returns stream<Database> {
        return self.st;
    }

    public function getHeaders() returns Headers {
        return self.headers;
    }

    public function getCount() returns int {
        return self.count;
    }
}