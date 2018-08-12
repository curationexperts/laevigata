/* global describe */
/* global it */
/* global expect */
import { shallowMount } from '@vue/test-utils'
import Keywords from '../../../components/submit/Keywords'
import { formStore } from '../../../formStore'

formStore.savedData.other_copyrights = 'true'
formStore.savedData.requires_permissions = 'false'
formStore.savedData.patents = 'true'
describe('Keywords.vue', () => {
  it('has the correct label', () => {
    const wrapper = shallowMount(Keywords, {
    })

    expect(wrapper.html()).toContain(`Yes, my thesis or dissertation contains copyrighted material.`)
    expect(wrapper.html()).toContain(`No, my thesis or dissertation does not require additional permissions.`)
    expect(wrapper.html()).toContain(`Yes, my thesis or dissertation contains patentable material.`)
  })
})
