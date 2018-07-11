/* global describe */
/* global it */
/* global expect */

import { formStore } from '../formStore'

describe('formStore', () => {
  it('returns the correct embargo length based on the selected school', () => {
    formStore.setSelectedSchool('emory')
    expect(formStore.getEmbargoLengths()).toEqual([{value: 'None - open access immediately', selected: 'selected'},
      {value: '6 Months'}, {value: '1 Year'}, {value: '2 Years'}])
  })

  it('returns the correct embargo contents', () => {
    expect(formStore.getEmbargoContents()).toEqual([{ text: 'Files',
    value: '[:files_embargoed]',
    disabled: false
  },
  { text: 'Files and Table of Contents',
    value: '[:files_embargoed, :toc_embargoed]',
    disabled: false
  },
  { text: 'Files and Table of Contents and Abstract',
    value: '[:files_embargoed, :toc_embargoed, :abstract_embargoed]',
    disabled: false
  }
                                                 ])
  })
})
