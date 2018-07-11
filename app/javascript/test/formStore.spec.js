/* global describe */
/* global it */
/* global expect */
import axios from 'axios'
import { formStore } from '../formStore'
jest.mock('axios')
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

  it('can add and return all the deletable supplemental files', () => {
    const deletableFile = { deleteType: 'DELETE',
      deleteUrl: '/uploads/2?locale=en',
      id: 2,
      name: 'sample.pdf',
      size: 19971 }

    formStore.addDeleteableSupplementalFile(deletableFile)
    expect(formStore.getDeleteableSupplementalFiles()).toEqual([deletableFile])
  })

  it('can delete a file from the supplemental files', () => {
    const resp = {data: ['']}
    axios.delete.mockResolvedValue(resp)
    const deleteUrl = formStore.deletableSupplementalFiles[0].deleteUrl
    expect(deleteUrl).toEqual('/uploads/2?locale=en')
    formStore.deleteSupplementalFile(deleteUrl, 'token')
    expect(formStore.deletableSupplementalFiles.length).toEqual(0)
  })
})
