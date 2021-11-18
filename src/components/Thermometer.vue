<template>
    <div class="container">
        <div class="totals">
            <div class="input-group">
                <span>Title</span>
                <input type="text" v-model="branchName" class="input">
            </div>
            <div class="input-group">
                <span>Goal</span>
                <currency-input
                    v-model="total"
                    class="input"
                />
            </div>
            <div class="input-group">
                <span>Current</span>
                <currency-input
                    v-model="amount"
                    class="input"
                />
            </div>
            <div>
                <button @click="saveToPDF" class="button">Save to PDF</button>
            </div>
        </div>
        <div class="main" id="main">
            <div ref="pdf" class="main-wrapper">
                <div class="tallies">
                    <div class="tick"></div>
                    <div class="tick"></div>
                    <div class="tick"></div>
                    <div class="tick"></div>
                    <div class="tick"></div>
                    <div class="tick"></div>
                    <div class="tick"></div>
                    <div class="tick"></div>
                    <div class="tick"></div>
                    <div class="tick"></div>
                    <div class="tick"></div>
                    <div class="tick"></div>
                    <div class="tick"></div>
                    <div class="tick"></div>
                    <div class="tick"></div>

                    <div v-if="total" class="tick-active" style="height: 100%">
                        <span class="tick-amount">{{ abbreviateNumber(total) }}</span>
                        <div class="tick tick-current"></div>
                    </div>

                    <div v-if="tempValid" class="tick-active" :style="`height: ${tempHeight}%`">
                        <span class="tick-amount is-brand">{{ abbreviateNumber(amount) }}</span>
                        <div class="tick tick-current is-brand"></div>
                    </div>
                </div>

                <div class="thermometer">
                    <div class="tube-container">
                        <div v-if="tempValid" class="tube" :style="`height: ${tempHeight}%`">

                        </div>
                    </div>
                    
                    <div class="bulb" :class="{'is-active': tempValid}">
                        <img alt="World Finance" src=".././assets/logo.png" class="world-logo">
                    </div>
                    <span class="bulb-shadow"></span>
                </div>
                <div class="content">
                    <div>
                        <span class="content-total current-branch">{{ branchName }}</span>
                        <span class="content-title">Goal:</span>
                        <span class="content-total current-goal">{{ abbreviateNumber(total, true) }}</span>
                        <span class="content-title">Current ledger:</span>
                        <span :class="{ 'goal-met' :goalMet }" class="content-total current-ledger">{{ currency(amount, '$', 0) }}</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import { jsPDF } from "jspdf";
import * as html2canvas from 'html2canvas';
import CurrencyInput from './CurrencyInput.vue';
import _debounce from 'lodash/debounce';

export default {
    components: { CurrencyInput },
        name: 'HelloWorld',
        props: {
        msg: String
    },
    data() {
        return {
            branchName: '',
            amount: 0,
            total: 0,
        }
    },
    created() {
        this.checkLocalStorage();
    },
    computed: {
        tempHeight() {
            return (this.amount/this.total)*100;
        },
        tempValid() {
            return this.tempHeight > 0;
        },
        goalMet() {
            return this.total && this.amount && (this.amount >= this.total);
        }
    },
    watch: {
        branchName: _debounce(function () {
            this.saveToLocalStorage();
        }, 1000),
        amount: _debounce(function () {
            this.saveToLocalStorage();
        }, 1000),
        total: _debounce(function () {
            this.saveToLocalStorage();
        }, 1000)
    },
    methods: {
        abbreviateNumber(value, full) {
            var newValue = value;
            if (value >= 1000) {
                let suffixes = ['', 'K', 'M', 'B', 'T'];
                if (full) {
                    suffixes = ['', 'thousand', 'million', 'billion','trillion'];
                }
                
                let suffixNum = Math.floor( (''+value).length/3 );
                let shortValue = '';
                for (let precision = 2; precision >= 1; precision--) {
                    shortValue = parseFloat( (suffixNum != 0 ? (value / Math.pow(1000,suffixNum) ) : value).toPrecision(precision));
                    let dotLessShortValue = (shortValue + '').replace(/[^a-zA-Z 0-9]+/g,'');
                    if (dotLessShortValue.length <= 2) { break; }
                }
                if (shortValue % 1 != 0)  shortValue = shortValue.toFixed(1);
                newValue = full ? shortValue + ` ${suffixes[suffixNum]}` : shortValue + suffixes[suffixNum];
            }
            return newValue;
        },
        currency(value, currency, decimals) {
            const digitsRE = /(\d{3})(?=\d)/g
            value = parseFloat(value)
            if (!isFinite(value) || (!value && value !== 0)) return ''
            currency = currency != null ? currency : '$'
            decimals = decimals != null ? decimals : 2
            var stringified = Math.abs(value).toFixed(decimals)
            var _int = decimals
                ? stringified.slice(0, -1 - decimals)
                : stringified
            var i = _int.length % 3
            var head = i > 0
                ? (_int.slice(0, i) + (_int.length > 3 ? ',' : ''))
                : ''
            var _float = decimals
                ? stringified.slice(-1 - decimals)
                : ''
            var sign = value < 0 ? '-' : ''
            return sign + currency + head +
            _int.slice(i).replace(digitsRE, '$1,') +
            _float
        },
        saveToPDF() {
            let pdfRef = this.$refs.pdf;
            html2canvas(pdfRef, {
                useCORS: true,
            })
            .then((canvas) => {
                const imgData = canvas.toDataURL('image/png');
                const pdf = new jsPDF({
                orientation: 'portrait',
                });
                const imgProps= pdf.getImageProperties(imgData);
                const pdfWidth = pdf.internal.pageSize.getWidth();
                const pdfHeight = (imgProps.height * pdfWidth) / imgProps.width;
                pdf.addImage(imgData, 'PNG', 30, 40, (pdfWidth * .75), (pdfHeight * .75));
                pdf.save('World Finance Ledger.pdf');
            });
        },
        checkLocalStorage() {
            const settings = JSON.parse(localStorage.getItem('settings'));

            if (settings) {
                this.branchName = settings.branchName;
                this.amount = settings.amount;
                this.total = settings.total;
            }
        },
        saveToLocalStorage () {
            let settings = {
                branchName: this.branchName,
                amount: this.amount,
                total: this.total,
            }

            localStorage.setItem('settings', JSON.stringify(settings));
        }
    }
}
</script>

<style scoped>    
@font-face {
    font-family: 'Mohr Rounded Bold';
    src: url("~@/assets/fonts/Latinotype - Mohr Rounded Bold.otf") format("opentype");
}

@font-face {
    font-family: 'Mohr Rounded SemiBold';
    src: url("~@/assets/fonts/Latinotype - Mohr Rounded SemiBold.otf") format("opentype");
}

@font-face {
    font-family: 'WorkSans-Regular';
    src: url("~@/assets/fonts/WorkSans-Regular.ttf") format("truetype");
}

.container {
    display: flex;
    width: 100%;
    flex-direction: column;
    font-family: 'WorkSans-Regular';
}

.main {
    position: relative;
    margin: 0 auto;
    margin-bottom: 20px;
    display: flex;
    width: 100%;
    justify-content: center;
    background-color: #fff;
}

.main-wrapper {
    display: flex;
    padding-bottom: 100px;
    padding-left: 60px;
    background-color: #fff;
    z-index: 1;
    transform: scale(0.65);
}

.content {
    display: flex;
    justify-content: flex-start;
    align-items: center;
    padding: 50px;
    width: 300px;
    flex-wrap: wrap;
    text-align: left;
    padding-left: 60px;
}

.button {
    font-family: 'Mohr Rounded SemiBold';
    display: flex;
    border-radius: 5px;
    padding: 8px 15px;
    font-size: 16px;
    border: none;
    margin-top: 20px;
    background-color: #002256;
    color: #fff;
    cursor: pointer;
    float: right;
    transition: opacity 250ms ease;
}

.button-print {
    margin-right: 15px;
}

.button:hover {
    opacity: 0.75;
}

.input {
    padding: 10px;
    font-size: 16px;
    border-radius: 5px;
    border: 1px solid #ccc;
    background-color: #f5fcff;
}

.input-group {
    display: flex;
}

.input-group + .input-group {
    margin-top: 20px;
}

.input-group span {
    width: 70px;
}

.content-total {
    display: block;
    width: 100%;
    font-size: 30px;
    padding: 0;
}

.current-goal {
    font-family: 'Mohr Rounded Bold';
    color: #44a3db;
    font-weight: bold;
    font-size: 40px;
    margin-bottom: 40px;    
}

.current-branch {
    margin-bottom: 20px;
}

.current-ledger {
    font-family: 'Mohr Rounded SemiBold';
    color: #2361ae;
    font-weight: bold;
    padding: 12px 10px;    
    text-align: center;
    margin-top: 10px;
    position: relative;
    left: -20px;
    background: #fff;
    border-radius: 50em;
    border: 3px solid transparent;
    position: relative;
}

.current-ledger:after {
    content: '';
    position: absolute;
    left: -6px;
    top: -6px;
    bottom: -6px;
    right: -6px;
    border-radius: 50em;
    background:
    linear-gradient(#44a3db, #2262ae) padding-box,
    linear-gradient(to right, #44a3db, #2262ae) border-box;
    z-index: -1;
}

.current-ledger.goal-met:after {
    background:
    linear-gradient(#ea8c70, #f26339) border-box,
    linear-gradient(to right, #ea8c70, #f26339) border-box;
}

.current-ledger.goal-met {
    color: #ffffff;
    background:
    linear-gradient(#ea8c70, #f26339) border-box,
    linear-gradient(to right, #ea8c70, #f26339) border-box;
}

.content-title {
    font-family: 'WorkSans-Regular';
    display: block;
    font-size: 24px;
    padding: 0;
}

.tallies {
    height: 550px;
    position: relative;
    border: 10px solid transparent;
}

.tick {
    width: 12px;
    height: 4px;
    border-radius: 5px;
    background-color: #d1d3d4;
    margin-bottom: 30px;
}

.tick.is-brand {
    background-color: #002256;
}

.tick-current {
    background-color: #f2633a;
    position: absolute;
    left: 0;
    margin-bottom: 0;
    transition: height 250ms ease;
}

.tick-active {
    position: absolute;
    bottom: 0;
    display: flex;
}

.tick-amount {
    font-family: 'Mohr Rounded Bold';
    position: absolute;
    right: 10px;
    padding: 0;
    font-weight: bold;
    font-size: 23px;
    top: -12px;
    color: #f2633a;
}

.tick-amount.is-brand {
    color: #2361ae;
    font-family: 'Mohr Rounded SemiBold';
}

.thermometer {
    height: 550px;
    width: 52px;
    background-color: #7ac5e0;
    border: 10px solid #ffffff;
    position: relative;
    display: flex;
    align-items: center;
    justify-content: center;    
    border-bottom: none;
    border-top-right-radius: 52px;
    border-top-left-radius: 52px;
}

.thermometer:before {
    content: '';
    position: absolute;
    width: 8px;
    background-color: #ffffff;
    opacity: 0.5;
    top: 25px;
    bottom: 10px;
    left: 8px;
    border-radius: 8px;
    z-index: 1;
}

.thermometer:after {
    content: '';
    position: absolute;
    top: -8px;
    bottom: 0;
    right: -21px;
    z-index: -2;
    border-top-right-radius: 52px;
    border-top-left-radius: 52px;
    width: 24px;
    background-position: right;
    background-repeat: no-repeat;
    background-image: url('~@/assets/img/shadow.png');
    background-size: cover;
}

.tube-container {
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    width: 100%;
    overflow: hidden;
    border-top-right-radius: 52px;
    border-top-left-radius: 52px;
    top: 0;
}

.tube {
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    width: 100%;
    background-color: #002256;
    transition: height 250ms ease;
    background: linear-gradient(90deg, #21548d 0%, #235791 50%, #26609f 100%);
}

span {
    padding: 10px;
}

.totals {
    display: flex;
    flex-direction: column;
    padding: 1em;
    box-shadow: 8px 4px 12px #aec0d9;
    border-radius: 20px;
    top: 20px;
    left: 20px;
    z-index: 10;
    margin-bottom: 30px;
}

@media only screen and (min-width: 768px) {
    .totals {
        position: absolute;
        margin-bottom: 0;
    }

    .container {
        flex-direction: row;
        padding-left: 310px;
    }

    .main-wrapper {
        transform: scale(1);
    }
}

.bulb {
    position: absolute;
    bottom: -98px;
    width: 96px;
    height: 96px;
    border-radius: 50%;
    border: 10px solid #ffffff;
    z-index: -1;
    display: flex;
    align-items: center;
    justify-content: center;
    background: linear-gradient(90deg, #75cde3 4%, #78c5e1 55%, #57b4dd 100%);
}

.bulb-shadow {
    content: '';
    background-image: url('~@/assets/img/circle-shadow.png');
    background-size: contain;
    position: absolute;
    bottom: -108px;
    width: 117px;
    height: 111px;
    left: -35px;
    z-index: -2;
}

.bulb.is-active {
    background: linear-gradient(90deg, #21548d 20%, #235791 50%, #26609f 80%);
}

.world-logo {
    width: 70px;
}

@media print {
    .totals {
        display: none;
    }

    .container {
        padding-left: 0;
    }

    .main-wrapper {
        transform: none;
    }
}
</style>
