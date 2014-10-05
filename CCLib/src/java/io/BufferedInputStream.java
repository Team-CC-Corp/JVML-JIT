package java.io;

public class BufferedInputStream extends FilterInputStream
{
    private static int DEFAULT_BUFFER_SIZE = 8192;
    private static int MAX_BUFFER_SIZE = Integer.MAX_VALUE - 8;

    protected byte[] buffer;
    protected int count;
    protected int pos;
    protected int markpos = -1;
    protected int marklimit;

    private InputStream getInIfOpen() throws IOException
    {
        InputStream input = in;
        if (input == null)
            throw new IOException("Stream closed");
        return input;

    }

    private byte[] getBufIfOpen() throws IOException
    {
        byte[] buffer = this.buffer;
        if (buffer == null)
            throw new IOException("Stream closed");
        return buffer;
    }

    private void fill() throws IOException
    {
        byte[] buffer = getBufIfOpen();
        if (markpos < 0)
            pos = 0;            /* no mark: throw away the buffer */
        else if (pos >= buffer.length)  /* no room left in buffer */
            if (markpos > 0)
            {  /* can throw away early part of the buffer */
                int sz = pos - markpos;
                System.arraycopy(buffer, markpos, buffer, 0, sz);
                pos = sz;
                markpos = 0;
            }
            else if (buffer.length >= marklimit)
            {
                markpos = -1;   /* buffer got too big, invalidate mark */
                pos = 0;        /* drop buffer contents */
            }
            else if (buffer.length >= MAX_BUFFER_SIZE)
            {
                //out of memory
            }
            else
            {            /* grow buffer */
                int nsz = (pos <= MAX_BUFFER_SIZE - pos) ?
                        pos * 2 : MAX_BUFFER_SIZE;
                if (nsz > marklimit)
                    nsz = marklimit;
                byte nbuf[] = new byte[nsz];
                System.arraycopy(buffer, 0, nbuf, 0, pos);
                buffer = nbuf;
            }
        count = pos;
        int n = getInIfOpen().read(buffer, pos, buffer.length - pos);
        if (n > 0)
            count = n + pos;
    }

    public BufferedInputStream(InputStream in)
    {
        this(in, DEFAULT_BUFFER_SIZE);
    }

    public BufferedInputStream(InputStream in, int size)
    {
        super(in);
        if (size <= 0)
        {
            throw new IllegalArgumentException("Buffer size <= 0");
        }
        buffer = new byte[size];
    }

    @Override
    public synchronized int read() throws IOException
    {
        if (pos >= count)
        {
            fill();
            if (pos >= count)
                return -1;
        }
        return getBufIfOpen()[pos++] & 0xff;
    }

    private int read1(byte[] b, int off, int len) throws IOException
    {
        int avail = count - pos;
        if (avail <= 0)
        {
            if (len >= getBufIfOpen().length && markpos < 0)
            {
                return getInIfOpen().read(b, off, len);
            }
            fill();
            avail = count - pos;
            if (avail <= 0) return -1;
        }
        int cnt = (avail < len) ? avail : len;
        System.arraycopy(getBufIfOpen(), pos, b, off, cnt);
        pos += cnt;
        return cnt;
    }

    public synchronized int read(byte b[], int off, int len)
            throws IOException
    {
        getBufIfOpen(); // Check for closed stream
        if ((off | len | (off + len) | (b.length - (off + len))) < 0)
        {
            throw new IndexOutOfBoundsException();
        }
        else if (len == 0)
        {
            return 0;
        }

        int n = 0;
        for (; ; )
        {
            int nread = read1(b, off + n, len - n);
            if (nread <= 0)
                return (n == 0) ? nread : n;
            n += nread;
            if (n >= len)
                return n;
            // if not closed but no bytes available, return
            InputStream input = in;
            if (input != null && input.available() <= 0)
                return n;
        }
    }

    public synchronized long skip(long n) throws IOException
    {
        getBufIfOpen(); // Check for closed stream
        if (n <= 0)
        {
            return 0;

        }
        long avail = count - pos;

        if (avail <= 0)
        {
            // If no mark position set then don't keep in buffer
            if (markpos < 0)
                return getInIfOpen().skip(n);

            // Fill in buffer to save bytes for reset
            fill();
            avail = count - pos;
            if (avail <= 0)
                return 0;

        }

        long skipped = (avail < n) ? avail : n;
        pos += skipped;
        return skipped;
    }

    public synchronized int available() throws IOException
    {
        int n = count - pos;
        int avail = getInIfOpen().available();
        return n > (Integer.MAX_VALUE - avail)
                ? Integer.MAX_VALUE
                : n + avail;
    }

    public synchronized void mark(int readlimit)
    {
        marklimit = readlimit;
        markpos = pos;
    }

    public synchronized void reset() throws IOException
    {
        getBufIfOpen(); // Cause exception if closed
        if (markpos < 0)
            throw new IOException("Resetting to invalid mark");
        pos = markpos;
    }

    public boolean markSupported()
    {
        return true;
    }

    public void close() throws IOException
    {
        this.buffer = null;
        if (this.in != null)
        {
            this.in.close();
            this.in = null;
        }
    }
}