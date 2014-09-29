/* Copyright (c) 2008-2010, Avian Contributors

   Permission to use, copy, modify, and/or distribute this software
   for any purpose with or without fee is hereby granted, provided
   that the above copyright notice and this permission notice appear
   in all copies.

   There is NO WARRANTY for this software.  See license.txt for
   details. */

package java.io;

import jvml.Utf8;

public class OutputStreamWriter extends Writer {
  private final OutputStream out;

  public OutputStreamWriter(OutputStream out) {
    this.out = out;
  }
  
  /**
   * Constructs a new OutputStreamWriter using {@code out} as the target
   * stream to write converted characters to and {@code charsetName} as the character
   * encoding. If the encoding cannot be found, an
   * UnsupportedEncodingException error is thrown.
   *
   * @param out
   *            the target stream to write converted bytes to.
   * @param charsetName
   *            the string describing the desired character encoding.
   * @throws NullPointerException
   *             if {@code charsetName} is {@code null}.
   * @throws UnsupportedEncodingException
   *             if the encoding specified by {@code charsetName} cannot be found.
   */
	public OutputStreamWriter(OutputStream out, final String charsetName) throws UnsupportedEncodingException {
		this(out);
		if (charsetName == null) {
			throw new NullPointerException("charsetName == null");
		}
		if (!charsetName.equals("UTF-8")) {
			throw new UnsupportedEncodingException(charsetName);
		}
	}
  
  public void write(char[] b, int offset, int length) throws IOException {
    out.write(Utf8.encode(b, offset, length));
  }

  public void flush() throws IOException {
    out.flush();
  }

  public void close() throws IOException {
    out.close();
  }
}
