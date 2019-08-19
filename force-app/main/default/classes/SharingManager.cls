public interface SharingManager {
    String execute(String buttonName, String paramsString);
    List<ListBuilderController.ShareInfo> getExisting(String approvalStepDefinitionId);
    String getSupportedButtons();
}