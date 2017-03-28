<dialog-choose-site>
    <div ref="modal" class="ui small modal" tabindex="-1" role="dialog" data-backdrop="static" style="margin-top: 20vh; width: 460px;margin-left: -16vw;">
        <!--<div class="header" style="border-bottom: 0">-->
        <!--Site url-->
        <!--<div class="sub header">E.g. /qq/demo-deploy-github</div>-->
        <!--</div>-->
        <div class="ui header" style="">
            <i class="globe icon" style=""></i>
            <div class="content" style="text-align: left">
                Choose site
            </div>
        </div>
        <div class="content">
            <form class="ui form error {loading : loading}">
                <div class="required field">
                    <div class="ui left input">
                        <input name="sitePath" ref="sitePathField" type="text" placeholder="/qq/demo-deploy-github" onkeypress="{input}">
                    </div>
                </div>

                <div show="{errorMsg != ''}" class="ui error message">
                    <p>{errorMsg}</p>
                </div>
                <div class="ui fluid blue button {disabled: !canSubmit()}" onclick="{submit}">Enter</div>
            </form>
        </div>
    </div>

    <script>
        var me = this;
        me.errorMsg = '';
        me.canSubmit = false;
        me.loading = false;

        var modal;

        me.canSubmit = function () {
            return me.refs.sitePathField.value;
        };

        me.input = function (e) {
            if (e.keyCode !== undefined && e.keyCode === 13) {
                me.submit();
                e.preventDefault();
            }
        };

        me.submit = function () {
//            me.loading = true;
            me.errorMsg = '';
            me.update();

            me.parent.trigger('chooseSite', me.refs.sitePathField.value);
        };

        me.on('mount', function () {
            console.log('before mount', $(me.refs.modal));
            if (!modal) {
                console.log('show');
                modal = $(me.refs.modal).modal({
                    closable: false
                });
            }
        });

        me.on('unmount', function () {
            console.log('hide login register dialog');
            me.hide();
        });

        me.hide = function() {
            if (!modal) return;
            me.errorMsg = '';
            modal.modal('hide');
        };

        me.show = function () {
            if (!modal) return;
            me.errorMsg = '';
            me.refs.sitePathField.value = '/qq/demo-deploy-github';
            modal.modal('show');
            me.update();
        }
    </script>

    <style></style>
</dialog-choose-site>

