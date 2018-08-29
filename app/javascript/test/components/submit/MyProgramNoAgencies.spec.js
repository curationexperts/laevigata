/* global describe */
/* global it */
/* global expect */
import Vue from 'vue'
import { shallowMount } from '@vue/test-utils'
import MyProgram from '../../../components/submit/MyProgram'
import { formStore } from '../../../formStore'

window.localStorage = jest.fn()
window.localStorage.getItem = jest.fn((value) =>{ return 'Rollins School of Public Health' })
formStore.savedData['partnering_agency'] = ['Does not apply (no collaborating organization)']
formStore.departments = [{'value':1,'active':true,'label':'Select a Department','disabled':'disabled','selected':'selected'},{'id':'Divinity','label':'Divinity','active':true},{'id':'Ministry','label':'Ministry','active':true},{'id':'Pastoral Counseling','label':'Pastoral Counseling','active':true},{'id':'Theological Studies','label':'Theological Studies','active':true}]
describe('MyProgram.vue with no agencies', () => {

  it('has the correct label', () => {
    const wrapper = shallowMount(MyProgram, {
    })
    wrapper.vm.managePartneringAgency()

    expect(wrapper.html()).toContain('Does not apply (no collaborating organization)')
  })

})
