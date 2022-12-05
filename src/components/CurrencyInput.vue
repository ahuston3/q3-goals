<template>
    <input :value="displayValue" type="number" inputmode="decimal" class="input" @input="updateValue" @blur="focused = false" @focus="focused = true">
</template>

<script>
export default {
    props: {
        value: {
            required: false,
            default: 0,
            validator: prop => typeof prop === 'string' || typeof prop === 'number' || prop === null
        }
    },
    data() {
        return {
            focused: false
        };
    },
    computed: {
        displayValue() {
            if (this.value === 0 || this.value > 0) {
                if (this.focused) {
                    return this.value.toString();
                } else {
                    return parseFloat(this.value).toFixed(0).replace(/(\d)(?=(\d{3})+(?:\.\d+)?$)/g, '$1,');
                }
            }
            return null;
        },
    },
    methods: {
        updateValue(event) {
            let value = event.target.value;
            value = parseFloat(value);
            this.$emit('input', value);
        },
    }
};
</script>