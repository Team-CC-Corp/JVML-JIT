package cc.turtle;

public class InspectionReport {
    
    private boolean success;
    private String errorMessage;
    private String blockName;
    private int blockMetadata;
    
    public InspectionReport() {
    }

    public boolean isSuccess() {
        return success;
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public String getBlockName() {
        return blockName;
    }

    public int getBlockMetadata() {
        return blockMetadata;
    }

}
