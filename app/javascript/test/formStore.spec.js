/* global describe */
/* global it */
/* global expect */

import { formStore } from '../formStore'

describe('formStore', () => {
  it('has copyrightQuestions', () => {
    expect(formStore.copyrightQuestions).toEqual(
      [{
        'label': 'Fair Use',
        'text': `Does your thesis or dissertation contain any thirdy-party text, audiovisual content or other material which is beyond a fair use and would require permission?`,
        'choice': 'no',
        'name': 'etd[requires_permissions]'
      }, {
        'label': 'Copyright',
        'text': `Does your thesis or dissertation contain content, such as a previously published article, for which you no longer own copyright? If you have quiestions about your use of copyrighted material, contact the Scholarly Communications Office at scholcom@listserv.cc.emory.edu`,
        'choice': 'no',
        'name': 'etd[additional_copyrights]'
      },
      {
        'label': 'Patents',
        'text': `Does your thesis or dissertation disclose or described any inventions or discoveries that could potentially have commerical application and therefore may be patended? If so please contact the Office of Technology Transfer (OTT) at (404) 727-2211.`,
        'choice': 'no',
        'name': 'etd[patents]'
      }]
    )
  })
})
