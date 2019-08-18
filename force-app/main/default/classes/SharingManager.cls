public interface SharingManager {
    String execute(String buttonName, String paramsString);
    String getExisting(String approvalStepDefinitionId);
    String getSupportedButtons();
}