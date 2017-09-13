class InputSanitizer
  # Remove any markup except the elements explicitly allowed here
  def self.sanitize(raw_input)
    clean_html = Sanitize.clean(
      raw_input,
      elements: [
        'b',
        'blockquote',
        'code',
        'em',
        'i',
        'p',
        'span',
        'strong',
        'style',
        'sup'
      ],
      attributes: {
        'p' => ['style'],
        'span' => ['style']
      },
      css: {
        properties: [
          'font-family',
          'margin',
          'padding',
          'text-align',
          'text-decoration',
          'width'
        ]
      }
    )
    CGI.unescapeHTML(clean_html.to_s)
  end
end
