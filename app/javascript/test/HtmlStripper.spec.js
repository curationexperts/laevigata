/* global describe */
/* global it */
/* global expect */
import HtmlStripper from '../HtmlStripper'

// This needs to check for both cases: visible / not-present
// now it tests that it isn't present
describe('HtmlStripper', () => {
  it('removes HTML tags from a string', () => {
    var htmlStripper = new HtmlStripper({
      html: '<p>Testing</p>'
    })
    expect(htmlStripper.strippedHtml()).toEqual('Testing')
  })
})
