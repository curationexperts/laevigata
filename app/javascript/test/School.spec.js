/* global describe */
/* global it */
/* global expect */
/* global jest */
import { mount } from '@vue/test-utils'
import School from 'School'
import axios from 'axios'
import { formStore } from 'formStore'

jest.mock('axios')

describe('School.vue', () => {
  const resp = {data: [{'id': 'Candler School of Theology'}]}
  axios.get.mockResolvedValue(resp)

  it('is a a select box before saving', () => {
    const wrapper = mount(School, {
    })
    wrapper.vm.$data.sharedState.schools.options = [{"text":"Select a School","value":"","disabled":"disabled","selected":"selected"},{"text":"Candler School of Theology","value":"candler"},{"text":"Emory College","value":"emory"},{"text":"Laney Graduate School","value":"laney"},{"text":"Rollins School of Public Health","value":"rollins"}]
    expect(wrapper.html()).toContain(`<div><label for="school">School</label> <select id="school" aria-required="true" class="form-control"><option disabled="disabled" value="">`)
  })

  it('is non-editable text after saving', () => {
    formStore.savedData.school = 'candler'

    const wrapper = mount(School, {
    })
    wrapper.vm.$data.sharedState.schools.options = [{"text":"Select a School","value":"","disabled":"disabled","selected":"selected"},{"text":"Candler School of Theology","value":"candler"},{"text":"Emory College","value":"emory"},{"text":"Laney Graduate School","value":"laney"},{"text":"Rollins School of Public Health","value":"rollins"}]
    expect(wrapper.html()).toContain(`<div><label for=\"school\">School</label> <!----> <div><b>Candler School of Theology</b></div></div>`)
  })
})
